import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A CloudConvert job that is waiting for its input file.
class ConversionJob {
  final String id;
  final String uploadUrl;
  final Map<String, dynamic> uploadParameters;
  const ConversionJob(this.id, this.uploadUrl, this.uploadParameters);
}

/// The converted file, as reported by the export task.
class ExportedFile {
  final String url;
  final String? filename;
  final int? sizeBytes;
  const ExportedFile({required this.url, this.filename, this.sizeBytes});
}

/// Thin client for the CloudConvert v2 API.
///
/// SECURITY: the API key is read from `.env`, which is bundled into the app.
/// Before publishing, move job creation behind your own backend and have this
/// class call that backend instead.
class FileService {
  static const _baseUrl = "https://api.cloudconvert.com/v2";
  static const _importTask = "import-file";
  static const _convertTask = "convert-file";
  static const _exportTask = "export-file";

  final Dio _dio;
  final String? _apiKey;

  FileService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _apiKey = apiKey ?? dotenv.env["API_KEY"];

  Options get _authorized => Options(headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      });

  /// Output formats grouped by category, e.g. {"document": ["pdf", "odt"]}.
  Future<Map<String, List<String>>> fetchValidOutputFormatsOf(
      String inputFormat) async {
    try {
      final res = await _dio.get(
        "$_baseUrl/convert/formats",
        queryParameters: {"filter[input_format]": inputFormat.toLowerCase()},
      );
      final formats = <String, List<String>>{};
      for (final item in res.data["data"] as List) {
        final String group = item["meta"]?["group"] ?? "other";
        final String output = item["output_format"];
        final list = formats.putIfAbsent(group, () => []);
        if (!list.contains(output)) list.add(output);
      }
      return formats;
    } on DioException catch (e) {
      _rethrow(e, (status) => ValidOutputFormatsFetchException(status));
    }
  }

  Future<ConversionJob> createJob(String inputFormat, String outputFormat,
      {CancelToken? cancelToken}) async {
    try {
      final res = await _dio.post(
        "$_baseUrl/jobs",
        options: _authorized,
        cancelToken: cancelToken,
        data: {
          "tasks": {
            _importTask: {"operation": "import/upload"},
            _convertTask: {
              "operation": "convert",
              "input": _importTask,
              "input_format": inputFormat.toLowerCase(),
              "output_format": outputFormat.toLowerCase(),
            },
            _exportTask: {"operation": "export/url", "input": _convertTask},
          }
        },
      );
      final data = res.data["data"];
      final importTask = _findTask(data["tasks"], _importTask);
      if (importTask == null) throw CreateJobException(res.statusCode);
      final form = importTask["result"]["form"];
      logger.i("Job created: ${data["id"]}");
      return ConversionJob(
        data["id"],
        form["url"],
        Map<String, dynamic>.from(form["parameters"] as Map),
      );
    } on DioException catch (e) {
      _rethrow(e, (status) => CreateJobException(status));
    }
  }

  Future<void> uploadFile({
    required ConversionJob job,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    var sentSoFar = 0;
    try {
      final formData = FormData();
      // CloudConvert expects the signed parameters before the file field.
      job.uploadParameters.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      formData.files.add(MapEntry(
        "file",
        await MultipartFile.fromFile(filePath, filename: fileName),
      ));
      await _dio.post(
        job.uploadUrl,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          sentSoFar = sent;
          onSendProgress?.call(sent, total);
        },
      );
    } on DioException catch (e) {
      _rethrow(e, (status) => UploadFileException(status, sentBytes: sentSoFar));
    }
  }

  /// Polls the job until the export task finishes.
  ///
  /// Throws [ConversionFailedException] if CloudConvert reports an error and
  /// [ConversionTimeoutException] after [timeout].
  Future<ExportedFile> waitForExport(
    String jobId, {
    CancelToken? cancelToken,
    Duration timeout = const Duration(minutes: 10),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    try {
      while (DateTime.now().isBefore(deadline)) {
        if (cancelToken?.isCancelled ?? false) {
          throw OperationCancelledException();
        }
        final res = await _dio.get("$_baseUrl/jobs/$jobId",
            options: _authorized, cancelToken: cancelToken);
        final data = res.data["data"];

        if (data["status"] == "error") {
          final failed = (data["tasks"] as List)
              .cast<Map>()
              .where((t) => t["status"] == "error")
              .toList();
          throw ConversionFailedException(
              failed.isNotEmpty ? failed.first["message"]?.toString() : null);
        }

        final export = _findTask(data["tasks"], _exportTask);
        if (export != null && export["status"] == "finished") {
          final file = (export["result"]["files"] as List).first;
          return ExportedFile(
            url: file["url"],
            filename: file["filename"],
            sizeBytes: file["size"] is int ? file["size"] : null,
          );
        }
        await Future.delayed(interval);
      }
      throw ConversionTimeoutException();
    } on DioException catch (e) {
      _rethrow(e, (status) => JobStatusException(status));
    }
  }

  /// Best effort: tells CloudConvert to stop and delete the job.
  Future<void> cancelJob(String jobId) async {
    try {
      await _dio.delete("$_baseUrl/jobs/$jobId", options: _authorized);
    } on DioException catch (e) {
      logger.w("Could not delete job $jobId: ${e.message}");
    }
  }

  /// Downloads [url] to [savePath], reporting progress from 0 to 1.
  Future<void> downloadFile(String url, String savePath,
      {void Function(double progress)? onProgress,
      CancelToken? cancelToken}) async {
    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        },
      );
    } on DioException catch (e) {
      _rethrow(e, (status) => DownloadFileException(status));
    }
  }

  Map? _findTask(dynamic tasks, String name) {
    for (final task in tasks as List) {
      if (task["name"] == name) return task as Map;
    }
    return null;
  }

  Never _rethrow(DioException e, Exception Function(int? status) onBadStatus) {
    logger.e(e);
    switch (e.type) {
      case DioExceptionType.cancel:
        throw OperationCancelledException();
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NoInternetConnectionException();
      default:
        throw onBadStatus(e.response?.statusCode);
    }
  }
}
