import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
// import 'dart:io';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class FileService {
  final String? apiKey = dotenv.env["API_KEY"];
  Dio dio = Dio();
  late String _jobId;
  late String _uploadUrl;
  late Map _parameters;

  Future<Map<String, List<String>>> fetchValidOutputFormatsOf(
      String inputFormat) async {
    Map<String, List<String>> validOutputFormats = {};
    try {
      String apiUrl =
          "https://api.cloudconvert.com/v2/convert/formats?filter[input_format]=$inputFormat";
      var res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);
        for (var map in resBody["data"]) {
          String group = map["meta"]["group"];
          validOutputFormats
              .putIfAbsent(group, () => [])
              .add(map["output_format"]);
        }
        return validOutputFormats;
      } else {
        throw ValidOutputFormatsFetchException(res.statusCode);
      }
    } on ValidOutputFormatsFetchException catch (e) {
      logger.e(e);
      rethrow;
    } on SocketException catch (e) {
      logger.e(e);
      throw ValidOutputFormatsSocketException();
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<void> creatJob(
    String inputFormat,
    String outputFormat,
  ) async {
    try {
      final String url = 'https://api.cloudconvert.com/v2/jobs';
      // Define the headers including your API key
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      };
      // Step 1: Create a job with an import/upload task and a convert task
      var jobBody = jsonEncode({
        "tasks": {
          'import-a2': {
            'operation': "import/upload",
          },
          "convert-a2": {
            "operation": "convert",
            "input": "import-a2",
            "input_format": inputFormat,
            "output_format": outputFormat,
          },
          "export-a2": {
            "operation": "export/url",
            "input": "convert-a2",
          }
        }
      });
      var response =
          await http.post(Uri.parse(url), headers: headers, body: jobBody);
      if (response.statusCode == 201) {
        logger.i("Job created");
        var responseBody = jsonDecode(response.body);
        final data = responseBody['data'];
        _jobId = data['id'];
        _uploadUrl = data['tasks'][0]['result']['form']['url'];
        _parameters = data['tasks'][0]['result']['form']['parameters'];
        logger.i("job id: $_jobId");
        logger.i("Upload URL: $_uploadUrl");
      } else {
        throw CreateJobException(response.statusCode);
      }
    } on CreateJobException catch (e) {
      logger.e(e);
      rethrow;
    } on SocketException catch (e) {
      logger.e(e);
      throw CreateJobSocketException();
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<void> uploadFile(
      {required String filePath,
      required String fileName,
      required void Function(int sent, int totat)? onSendProgress}) async {
    // Create the multipart request
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath,
            filename: fileName //show only filename from path
            ),
      });
      _parameters.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });
      var uploadResponse = await dio.post(
        _uploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onSendProgress != null) {
            onSendProgress(sent, total); // Pass progress to the callback
          }
        },
      );
      if (uploadResponse.statusCode != 201) {
        throw UploadFileException(uploadResponse.statusCode!);
      }
    } on UploadFileException catch (e) {
      logger.e(e);
      rethrow;
    } on SocketException catch (e) {
      logger.e(e);
      throw UploadFileSocketException();
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<String> getFileDownloadUrl(String jobId) async {
    try {
      final String jobStatusUrl = 'https://api.cloudconvert.com/v2/jobs/$jobId';
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      };

      // Poll for job status
      while (true) {
        final response =
            await http.get(Uri.parse(jobStatusUrl), headers: headers);
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final exportTask = responseBody['data']['tasks'].firstWhere(
              (task) => task['name'] == 'export-a2',
              orElse: () => null);

          if (exportTask != null && exportTask['status'] == 'finished') {
            final String url = exportTask['result']['files'][0]['url'];
            return url;
          } else {
            logger.i('-------- Waiting for file conversion to complete...');
            await Future.delayed(
                const Duration(seconds: 1)); // Wait before polling again
          }
        } else {
          throw FetchFileDownloadUrlException(response.statusCode);
        }
      }
    } on FetchFileDownloadUrlException catch (e) {
      logger.e(e);
      rethrow;
    } on SocketException catch (e) {
      logger.e(e);
      throw FetchFileDownloadUrlSocketException();
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  String getJobId() {
    // return "eac37abe-5cd1-4d3b-bde5-d817adef6bbe";
    return _jobId;
  }

  Future<int> fetchFileSize(String fileUrl) async {
    try {
      // HEAD request didn't work with me, so I used Get
      var response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        String? contentLength = response.headers['content-length'];
        int fileSize = int.parse(contentLength!);
        return fileSize;
      } else {
        throw FetchFileSizeException(response.statusCode);
      }
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
