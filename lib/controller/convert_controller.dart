import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/constant/app_config.dart';
import 'package:convertify/core/exception/exceptions_handler.dart';
import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/data/preferences_helper.dart';
import 'package:convertify/model/converting_file_model.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/model/selected_file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/utils/file_utils.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:convertify/utils/network_utils.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Where the user is in the convert flow. The Convert tab renders one view
/// per stage.
enum ConvertStage { idle, ready, uploading, converting, done, failed }

/// Which step a failure happened in, so retry knows what to redo.
enum FailedStep { upload, convert }

class ConvertController extends GetxController {
  ConvertController({
    required PreferencesHelper prefs,
    required FilesController files,
    FileService? service,
  })  : _prefs = prefs,
        _files = files,
        _service = service ?? FileService();

  final PreferencesHelper _prefs;
  final FilesController _files;
  final FileService _service;

  final Rx<ConvertStage> stage = ConvertStage.idle.obs;

  final Rxn<SelectedFileModel> selectedFile = Rxn<SelectedFileModel>();
  final RxString outputFormat = "".obs;

  final RxMap<String, List<String>> validOutputFormats =
      <String, List<String>>{}.obs;
  final RxBool isFormatsLoading = false.obs;
  final Rxn<AppError> formatsError = Rxn<AppError>();

  final RxDouble uploadProgress = 0.0.obs;
  final RxInt uploadedBytes = 0.obs;

  final Rxn<DownloadableFileModel> result = Rxn<DownloadableFileModel>();
  final Rx<Duration> conversionTook = Duration.zero.obs;

  final Rxn<AppError> error = Rxn<AppError>();
  final Rx<FailedStep> failedStep = FailedStep.upload.obs;

  /// Name and formats shown while converting. Set from [selectedFile], or from
  /// the saved job when resuming after a restart.
  final RxString activeFileName = "".obs;
  final RxString activeInputFormat = "".obs;
  final RxString activeFileSize = "".obs;

  CancelToken? _cancelToken;
  String? _jobId;
  DateTime? _startedAt;

  /// Bumped on every new run so a stale run can't overwrite newer state.
  int _run = 0;

  bool get isBusy =>
      stage.value == ConvertStage.uploading ||
      stage.value == ConvertStage.converting;

  bool get canConvert =>
      selectedFile.value != null &&
      outputFormat.value.isNotEmpty &&
      !isBusy;

  /// False when there is nothing left to retry (e.g. a resumed job failed
  /// after the original file was gone).
  bool get canRetry =>
      selectedFile.value != null ||
      (failedStep.value == FailedStep.convert &&
          _prefs.fetchConvertingFile() != null);

  /// The step indicator: 0 = file, 1 = format, 2 = convert.
  int get currentStep {
    if (selectedFile.value == null) return 0;
    if (outputFormat.value.isEmpty) return 1;
    return 2;
  }

  @override
  void onInit() {
    super.onInit();
    _resumePendingJob();
  }

  // ---------------------------------------------------------------- picking

  /// Picks a file and loads the formats it can become.
  ///
  /// Returns true when the format sheet should open next.
  Future<bool> pickFile({String? onlyExtension, String? preferredOutput}) async {
    try {
      await NetworkUtils.checkInternet();
      final picked = await FileUtils.pickFile(
          allowedExtensions: onlyExtension == null ? null : [onlyExtension]);

      final ext = (picked.extension ?? FormatUtils.extensionOf(picked.name))
          ?.toLowerCase();
      final path = picked.path;
      if (ext == null || ext.isEmpty || path == null) {
        throw FileFormatUnknownException();
      }
      if (picked.size > AppConfig.fileSizeLimitInMB * 1024 * 1024) {
        throw FileTooLargeException(AppConfig.fileSizeLimitInMB);
      }

      selectedFile.value = SelectedFileModel(
          path: path, name: picked.name, sizeBytes: picked.size, extension: ext);
      outputFormat.value = "";
      result.value = null;
      error.value = null;
      stage.value = ConvertStage.ready;

      await loadFormats();
      final all = validOutputFormats.values.expand((e) => e);
      if (preferredOutput != null && all.contains(preferredOutput)) {
        outputFormat.value = preferredOutput;
        return false;
      }
      return formatsError.value == null;
    } catch (e) {
      ExceptionsHandler.handle(e, "An error occurred while picking a file");
      return false;
    }
  }

  Future<void> loadFormats() async {
    final file = selectedFile.value;
    if (file == null) return;
    isFormatsLoading.value = true;
    formatsError.value = null;
    try {
      validOutputFormats.assignAll(
          await _service.fetchValidOutputFormatsOf(file.extension));
    } catch (e) {
      logger.e(e);
      validOutputFormats.clear();
      formatsError.value = ExceptionsHandler.describe(e);
    } finally {
      isFormatsLoading.value = false;
    }
  }

  void selectFormat(String format) => outputFormat.value = format;

  // ------------------------------------------------------------- converting

  Future<void> startConversion() async {
    final file = selectedFile.value;
    if (file == null || outputFormat.value.isEmpty || isBusy) return;
    // First conversion: ask where files go. Converting still works without a
    // folder; the result waits in the Files tab until one is picked.
    await _files.ensureFolder();
    if (isBusy) return;

    final run = ++_run;
    final token = _cancelToken = CancelToken();
    final output = outputFormat.value;
    activeFileName.value = file.name;
    activeInputFormat.value = file.extension;
    activeFileSize.value = file.size;
    uploadProgress.value = 0;
    uploadedBytes.value = 0;
    error.value = null;
    stage.value = ConvertStage.uploading;

    try {
      await NetworkUtils.checkInternet();
      final job = await _service.createJob(file.extension, output,
          cancelToken: token);
      _jobId = job.id;
      await _service.uploadFile(
        job: job,
        filePath: file.path,
        fileName: file.name,
        cancelToken: token,
        onSendProgress: (sent, total) {
          if (run != _run) return;
          uploadedBytes.value = sent;
          if (total > 0) uploadProgress.value = sent / total;
        },
      );
      if (run != _run) return;

      stage.value = ConvertStage.converting;
      _startedAt = DateTime.now();
      await _prefs.storeConvertingFile(ConvertingFileModel(
        fileName: file.name,
        fileSize: file.size,
        inputFormat: file.extension,
        outputFormat: output,
        jobId: job.id,
      ));
      await _waitAndStore(run, job.id, file.name, output, token);
    } catch (e) {
      _onFailure(run, e);
    }
  }

  /// Retry from the step that failed. A dropped connection while converting
  /// resumes polling the same job instead of uploading again.
  Future<void> retry() async {
    final pending = _prefs.fetchConvertingFile();
    if (failedStep.value == FailedStep.convert && pending != null) {
      final run = ++_run;
      final token = _cancelToken = CancelToken();
      error.value = null;
      stage.value = ConvertStage.converting;
      try {
        await _waitAndStore(
            run, pending.jobId, pending.fileName, pending.outputFormat, token);
      } catch (e) {
        _onFailure(run, e);
      }
    } else {
      await startConversion();
    }
  }

  /// Cancels the upload or the conversion and goes back to the ready state.
  Future<void> cancel() async {
    _run++; // detach the running flow
    _cancelToken?.cancel();
    _cancelToken = null;
    final jobId = _jobId;
    _jobId = null;
    if (jobId != null) {
      await _service.cancelJob(jobId);
    }
    await _prefs.removeConvertingFile();
    error.value = null;
    stage.value =
        selectedFile.value == null ? ConvertStage.idle : ConvertStage.ready;
  }

  /// Back to an empty home screen.
  void reset() {
    if (isBusy) return;
    selectedFile.value = null;
    outputFormat.value = "";
    validOutputFormats.clear();
    formatsError.value = null;
    result.value = null;
    error.value = null;
    stage.value = ConvertStage.idle;
  }

  // -------------------------------------------------------------- internals

  Future<void> _waitAndStore(int run, String jobId, String originalName,
      String output, CancelToken token) async {
    _jobId = jobId;
    final exported = await _service.waitForExport(jobId, cancelToken: token);
    if (run != _run) return;

    final now = DateTime.now();
    final model = DownloadableFileModel(
      fileId: GenerateUtils.generateIdWithDate("Convertify"),
      // Uses the converted name (the old resume path kept the input extension).
      fileName: exported.filename ??
          FormatUtils.changeFileExtension(originalName, output),
      fileSize: exported.sizeBytes == null
          ? ""
          : FormatUtils.formatFileSizeWithUnits(exported.sizeBytes!),
      fileOutputFormat: output,
      fileDownloadUrl: exported.url,
      convertedAt: now,
      linkExpiresAt: now.add(AppConfig.downloadLinkLifetime),
    );
    await _files.add(model);
    await _prefs.removeConvertingFile();
    _jobId = null;
    _cancelToken = null;
    conversionTook.value =
        _startedAt == null ? Duration.zero : now.difference(_startedAt!);
    result.value = model;
    stage.value = ConvertStage.done;
  }

  void _onFailure(int run, Object e) {
    if (run != _run) return; // superseded by cancel() or a newer run
    if (e is OperationCancelledException) {
      stage.value =
          selectedFile.value == null ? ConvertStage.idle : ConvertStage.ready;
      return;
    }
    logger.e("Conversion failed: $e");
    failedStep.value = stage.value == ConvertStage.uploading
        ? FailedStep.upload
        : FailedStep.convert;

    // A dropped connection while converting keeps the job so retry (or the
    // next app start) can pick it up. A real conversion failure forgets it.
    final keepJob = failedStep.value == FailedStep.convert &&
        e is NoInternetConnectionException;
    if (!keepJob) {
      _prefs.removeConvertingFile();
      _jobId = null;
    }
    _cancelToken = null;
    error.value = ExceptionsHandler.describe(e);
    stage.value = ConvertStage.failed;
  }

  /// If the app was killed mid-conversion, show the progress screen again and
  /// keep waiting for that job.
  Future<void> _resumePendingJob() async {
    final pending = _prefs.fetchConvertingFile();
    if (pending == null) return;
    activeFileName.value = pending.fileName;
    activeInputFormat.value = pending.inputFormat;
    activeFileSize.value = pending.fileSize;
    outputFormat.value = pending.outputFormat;
    failedStep.value = FailedStep.convert;
    _startedAt = null; // unknown after a restart; the done screen hides it

    final run = ++_run;
    final token = _cancelToken = CancelToken();
    stage.value = ConvertStage.converting;
    try {
      await _waitAndStore(
          run, pending.jobId, pending.fileName, pending.outputFormat, token);
    } catch (e) {
      _onFailure(run, e);
    }
  }
}
