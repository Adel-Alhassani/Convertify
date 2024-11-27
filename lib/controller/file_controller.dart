import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:convertify/core/exception/exceptions_handler.dart';
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
import 'package:convertify/utils/permission_utils.dart';
import 'package:convertify/utils/storage_utils.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:convertify/view/widget/downloadable_file_info.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/validator_utils.dart';

class FileController extends GetxController {
  SelectedFileModel selectedFile = SelectedFileModel();
  final Dio _dio = Dio();
  final FileService _fileService = FileService();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  RxBool isFilePicked = false.obs;
  RxBool isFileConverting = false.obs;
  RxBool isFileUploading = false.obs;
  RxBool isValidOutputFormatLoading = false.obs;
  int fileSizeLimitInMB = 30;
  int downloadableFilesListLimit = 15;
  RxString outputFormat = "".obs;
  RxInt fileLength = 0.obs;
  RxMap<String, List<String>> validOutputFormats = <String, List<String>>{}.obs;
  var convertingFile = ConvertingFileModel().obs;
  RxList<DownloadableFileModel> downloadableFiles =
      <DownloadableFileModel>[].obs;
  RxList<DownloadableFileModel> searchResult = <DownloadableFileModel>[].obs;
  RxMap<String, String> files = <String, String>{}.obs;
  RxMap<String, RxString> convertedDates = <String, RxString>{}.obs;
  Map<String, Timer> convertedDatesTimer = <String, Timer>{};
  RxMap<String, RxString> expiredDates = <String, RxString>{}.obs;
  Map<String, Timer> expiredDatesTimer = <String, Timer>{};
  RxDouble uploadProgress = 0.0.obs;
  RxMap<String, RxDouble> downloadProgress = <String, RxDouble>{}.obs;
  RxMap<String, RxBool> isFileDownloading = <String, RxBool>{}.obs;
  GlobalKey<AnimatedListState> listKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    logger.i("loading data");
    // removeConvertingFile();
    _loadConvertingFileData();
    _loadDownloadableFilesData();
    logger.i("data laoded");
  }

  void _loadConvertingFileData() async {
    ConvertingFileModel? data = _preferencesHelper.fetchConvertingFileData();
    if (data != null) {
      isFileConverting.value = true;
      String fileId = "${GenerateUtils.generateIdWithDate("Convertify")}";
      String fileConvertedDate = DateTime.now().toString();
      String fileExpireDate =
          DateTime.now().add(const Duration(hours: 24)).toString();
      await _storeDownloadableFiles(fileId, data.fileName!, data.outputFormat,
          fileConvertedDate, fileExpireDate);
      setConvertedDate(fileId, fileConvertedDate);
      setExpireDate(fileId, fileExpireDate);
      await removeConvertingFile();
      isFileConverting.value = false;
    }
  }

  void _loadDownloadableFilesData() {
    List<DownloadableFileModel>? downloadadableDataFiles =
        _preferencesHelper.fetchDownloadableFilesData();
    if (downloadadableDataFiles != null && downloadadableDataFiles.isNotEmpty) {
      downloadableFiles.value = downloadadableDataFiles;
      setConvertedDates(downloadableFiles);
      setExpiredDates(downloadableFiles);
    }
  }

  pickFile() async {
    try {
      await NetworkUtils.checkInternet();
      outputFormat.value = "";
      PlatformFile file = await FileUtils.pickFile();
      fileLength.value = file.size;
      if (!ValidateUtils.validateFileSize(file.size, fileSizeLimitInMB)) {
        return;
      }
      selectedFile.set(file.path, file.name, file.size, file.extension);
      await getValidOutputFormats(selectedFile.extension!);
      isFilePicked.value = true;
    } on Exception catch (e) {
      ExceptionsHandler.handle(e, "An error occurred while picking a file.");
    }
  }

  Future<bool> startFileUpload() async {
    if (isDownloadableFilesListLimitReached()) {
      CustomeDialog.showDownloadableFilesListLimitError();
      return false;
    }
    isFileUploading.value = true;
    await _fileService.creatJob(selectedFile.extension!, outputFormat.value);
    await _fileService.uploadFile(
      filePath: selectedFile.path!,
      fileName: selectedFile.name!,
      onSendProgress: (sent, totat) {
        uploadProgress.value = sent / totat;
      },
    );
    isFileUploading.value = false;
    logger.i("File uploaded");
    return true;
  }

  Future<void> convertFile() async {
    try {
      String jobId = _fileService.getJobId();
      await _storeConvertingFile(selectedFile.name!, selectedFile.size!,
          selectedFile.extension!, outputFormat.value, jobId);
      isFileConverting.value = true;
      String fileId = "${GenerateUtils.generateIdWithDate("Convertify")}";
      String fileConvertedDate = DateTime.now().toString();
      String fileExpireDate =
          DateTime.now().add(const Duration(hours: 24)).toString();
      await _storeDownloadableFiles(
          fileId,
          FormatUtils.changeFileExtension(
              selectedFile.name!, outputFormat.value),
          outputFormat.value,
          fileConvertedDate,
          fileExpireDate);
      setConvertedDate(fileId, fileConvertedDate);
      setExpireDate(fileId, fileExpireDate);
      await removeConvertingFile();
    } on Exception catch (e) {
      ExceptionsHandler.handle(e, "Failed to convert the file");
    } finally {
      removeConvertingFile();
      isFileConverting.value = false;
    }
  }

  void downloadFile(String fileId, String fileName, String downloadUrl) async {
    try {
      await NetworkUtils.checkInternet();
      PermissionUtils.getStoragePermission();
      final String fileDownloadUrl = downloadUrl;
      final String appDir = await StorageUtils.getAppDirectory();
      isFileDownloading[fileId] = true.obs;
      await _dio.download(
        fileDownloadUrl,
        "$appDir/$fileName",
        onReceiveProgress: (count, total) {
          if (total != -1) {
            downloadProgress[fileId] =
                FormatUtils.formatFileSize(count / total).obs;
          }
        },
      );
      CustomeDialog.showSuccessFileDownloadDialog(appDir);
    } on Exception catch (e) {
      ExceptionsHandler.handle(e, "Failed to download the file");
    } finally {
      isFileDownloading[fileId] = false.obs;
    }
  }

  bool isDownloadableFilesListLimitReached() {
    return downloadableFiles.length >= downloadableFilesListLimit;
  }

  Future<void> getValidOutputFormats(String extension) async {
    try {
      isValidOutputFormatLoading.value = true;
      validOutputFormats.value =
          await _fileService.fetchValidOutputFormatsOf(extension);
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    } finally {
      isValidOutputFormatLoading.value = false;
    }
  }

  Future<void> removeConvertingFile() async {
    await _preferencesHelper.removeConvertingFileData();
    convertingFile.update((convertingFile) {
      convertingFile!.clear();
    });
  }

  Future<void> _storeConvertingFile(String fileName, String fileSize,
      String fileExtension, String fileOutputFormat, String jobId) async {
    try {
      await _preferencesHelper.storeConvertingFileData(
          fileName, fileSize, fileExtension, fileOutputFormat, jobId);
      convertingFile.update((convertingFile) {
        convertingFile!.setFields(
            fileName: fileName,
            fileSize: fileSize,
            inputFormat: fileExtension,
            outputFormat: fileOutputFormat,
            jobId: jobId);
      });
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<void> _storeDownloadableFiles(String fileId, String fileName,
      fileOutputFormat, String fileConvertedDate, fileExpireDate) async {
    try {
      String fileDownloadUrl = await getDownloadUrl();
      String fileSize = FormatUtils.formatFileSizeWithUnits(
          await _fileService.fetchFileSize(fileDownloadUrl));
      await _preferencesHelper.storeDownloadableFilesData(
          fileId,
          fileName,
          fileSize,
          fileOutputFormat,
          fileDownloadUrl,
          fileConvertedDate,
          fileExpireDate);
      downloadableFiles.add(DownloadableFileModel(
          fileId: fileId,
          fileName: fileName,
          fileSize: fileSize,
          fileOutputFormat: fileOutputFormat,
          fileDownloadUrl: fileDownloadUrl,
          fileConvertedDate: fileConvertedDate,
          fileExpireDate: fileExpireDate));
      listKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 400));
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  void setConvertedDate(String fileId, date) {
    // only for the firs time will excute this
    // but after it enter the Timer block it'll not excute it
    // -----------------------------
    convertedDates[fileId] =
        FormatUtils.formatTimeAgo(DateTime.parse(date)).obs;
    // -----------------------------
    convertedDatesTimer[fileId] =
        Timer.periodic(const Duration(minutes: 1), (timer) {
      convertedDates[fileId] =
          FormatUtils.formatTimeAgo(DateTime.parse(date)).obs;
    });
  }

  void setExpireDate(String fileId, date) {
    // only for the firs time will excute this
    // but after it enter the Timer block it'll not excute it
    // -----------------------------
    expiredDates[fileId] =
        FormatUtils.formatExpireTime(DateTime.parse(date)).obs;
    if (int.parse(expiredDates[fileId]!.value) <= 0) {
      deleteDownloadableFile(fileId);
    }
    // -----------------------------
    expiredDatesTimer[fileId] =
        Timer.periodic(const Duration(hours: 1), (timer) {
      expiredDates[fileId] =
          FormatUtils.formatExpireTime(DateTime.parse(date)).obs;
      if (int.parse(expiredDates[fileId]!.value) <= 0) {
        deleteDownloadableFile(fileId);
        timer.cancel();
      }
    });
  }

  void setConvertedDates(List<DownloadableFileModel> downloadableFiles) {
    for (int i = 0; i < downloadableFiles.length; i++) {
      String fileId = downloadableFiles[i].fileId!;
      String fileConvertedDate = downloadableFiles[i].fileConvertedDate!;
      setConvertedDate(fileId, fileConvertedDate);
    }
  }

  void setExpiredDates(List<DownloadableFileModel> downloadableFiles) {
    for (int i = 0; i < downloadableFiles.length; i++) {
      String fileId = downloadableFiles[i].fileId!;
      String fileExpireDate = downloadableFiles[i].fileExpireDate!;
      setExpireDate(fileId, fileExpireDate);
    }
  }

  void deleteDownloadableFile(String fileId) async {
    if (await _preferencesHelper.deleteDownloadableFile(fileId)) {
      final int fileIndex =
          downloadableFiles.indexWhere((file) => file.fileId == fileId);
      DownloadableFileModel deletedItem = downloadableFiles.removeAt(fileIndex);
      listKey.currentState?.removeItem(downloadableFiles.length - fileIndex,
          (context, animation) {
        return FadeTransition(
          opacity: animation,
          child: Column(
            children: [
              DownloadableFileInfo(
                  fileId: deletedItem.fileId!,
                  fileName: deletedItem.fileName!,
                  fileSize: deletedItem.fileSize!,
                  fileExtension: deletedItem.fileOutputFormat!,
                  downloadUrl: deletedItem.fileDownloadUrl!,
                  convertedDate: convertedDates[deletedItem.fileId]!.value,
                  expireDate: expiredDates[deletedItem.fileId]!.value),
              SizedBox(
                height: 24.h,
              )
            ],
          ),
        );
      }, duration: const Duration(milliseconds: 400));
      cancelAndRemoveTimers(fileId);
    } else {
      CustomeDialog.showDeleteFailedDialog();
    }
  }

  void cancelAndRemoveTimers(String fileId) {
    convertedDatesTimer[fileId]!.cancel();
    convertedDatesTimer.remove(fileId);
    expiredDatesTimer[fileId]!.cancel();
    expiredDatesTimer.remove(fileId);
  }

  Future<String> getDownloadUrl() async {
    String jobId = _preferencesHelper.fetchJobId();
    String downloadUrl = await _fileService.getFileDownloadUrl(jobId);
    return downloadUrl;
  }

  void searchFor(String value) {
    if (value.isEmpty) {
      searchResult.clear();
      return;
    }
    searchResult.value = downloadableFiles
        .where((file) => file.fileName!.toLowerCase().contains(value))
        .toList();
  }
}
