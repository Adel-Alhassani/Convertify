import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/exception/exceptions_handler.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/data/preferences_helper.dart';
import 'package:convertify/model/converting_file_model.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/file_utils.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:convertify/utils/network_utils.dart';
import 'package:convertify/utils/permission_utils.dart';
import 'package:convertify/utils/storage_utils.dart';
import 'package:convertify/view/screen/my_files_screen.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/validator_utils.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class FileController extends GetxController {
  final Dio _dio = Dio();
  final FileService _fileService = FileService();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  RxBool isFilePicked = false.obs;
  RxBool isFileConverting = false.obs;
  RxBool isFileUploading = false.obs;
  RxBool isValidOutputFormatLoading = false.obs;
  int fileSizeLimitInMB = 30;
  RxString outputFormat = "".obs;
  String? path;
  String? name;
  String? size;
  String? extension;
  RxMap<String, List<String>> validOutputFormats = <String, List<String>>{}.obs;
  var convertingFile = ConvertingFileModel().obs;
  RxList<DownloadableFileModel> downloadableFiles =
      <DownloadableFileModel>[].obs;
  RxMap<String, String> files = <String, String>{}.obs;
  RxList searchResult = <Map<String, String>>[].obs;
  RxMap<String, RxString> convertedDates = <String, RxString>{}.obs;
  RxMap<String, RxString> expiredDates = <String, RxString>{}.obs;
  RxMap<String, RxDouble> downloadProgress = <String, RxDouble>{}.obs;
  RxMap<String, RxBool> isFileDownloading = <String, RxBool>{}.obs;
  // Logger logger = Logger();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    logger.i("loading data");
    // await _preferencesHelper.removeAllADateFromSharedPref();
    _loadConvertingFileData();
    _loadDownloadableFilesData();
    logger.i("data laoded");
  }

  void _loadConvertingFileData() async {
    ConvertingFileModel? data = await _getConvertingFileData();
    if (data != null) {
      logger.i(data);
      isFileConverting.value = true;
      String fileId = "${GenerateUtils.generateIdWithDate("Convertify")}";
      String fileConvertedDate = DateTime.now().toString();
      String fileExpireDate =
          DateTime.now().add(const Duration(minutes: 5)).toString();
      await _setDownloadableFiles(fileId, data.fileName!, data.outputFormat,
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

  Future<void> setFilePropretis(
      String? path, String? name, int size, String? extension) async {
    if (extension == null) throw FileFormatUnknownException;
    await getValidOutputFormatsOf(extension);
    this.path = path;
    this.name = name;
    this.size = FormatUtils.formatFileSizeWithUnits(size);
    this.extension = extension;
  }

  Future<void> getValidOutputFormatsOf(String format) async {
    try {
      isValidOutputFormatLoading.value = true;
      validOutputFormats.value =
          await _fileService.fetchValidOutputFormatsOf(format);
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    } finally {
      isValidOutputFormatLoading.value = false;
    }
  }

  pickFile() async {
    try {
      await NetworkUtils.checkInternet();
      outputFormat.value = "";
      PlatformFile selectedFile = await FileUtils.pickFile();
      if (!ValidateUtils.validateFileSize(
          selectedFile.size, fileSizeLimitInMB)) {
        return;
      }
      await setFilePropretis(selectedFile.path, selectedFile.name,
          selectedFile.size, selectedFile.extension);
      isFilePicked.value = true;
    } on Exception catch (e) {
      ExceptionsHandler.handle(e, "An error occurred while picking a file.");
    }
  }

  Future<void> startFileUpload() async {
    isFileUploading.value = true;
    await _fileService.creatJob(extension!, outputFormat.value);
    await _fileService.uploadFile(path!);
    isFileUploading.value = false;
    logger.i("File uploaded");
  }

  Future<void> convertFile() async {
    try {
      String jobId = _fileService.getJobId();
      await _setConvertingFile(
          name!, size!, extension!, outputFormat.value, jobId);
      isFileConverting.value = true;
      String fileId = "${GenerateUtils.generateIdWithDate("Convertify")}";
      String fileConvertedDate = DateTime.now().toString();
      String fileExpireDate =
          DateTime.now().add(const Duration(hours: 24)).toString();
      await _setDownloadableFiles(
          fileId, name!, outputFormat.value, fileConvertedDate, fileExpireDate);
      setConvertedDate(fileId, fileConvertedDate);
      setExpireDate(fileId, fileExpireDate);
      await removeConvertingFile();
      isFileConverting.value = false;
      logger.i("File converted");
    } on Exception catch (e) {
      ExceptionsHandler.handle(e, "Failed to convert the file");
    }
  }

  Future<void> removeConvertingFile() async {
    await _preferencesHelper.removeConvertingFileData();
    convertingFile.update((convertingFile) {
      convertingFile!.clear();
    });
    logger.i("Converting file cleared");
  }

  Future<void> _setConvertingFile(String fileName, String fileSize,
      String fileExtension, String fileOutputFormat, String jobId) async {
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
  }

  Future<void> _setDownloadableFiles(String fileId, String fileName,
      fileOutputFormat, String fileConvertedDate, fileExpireDate) async {
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
  }

  void setConvertedDate(String fileId, date) {
    // only for the firs time will excute this
    // but after it enter the Timer block it'll not excute this
    // -----------------------------
    convertedDates[fileId] =
        FormatUtils.formatTimeAgo(DateTime.parse(date)).obs;
    // -----------------------------
    Timer.periodic(const Duration(minutes: 1), (timer) {
      convertedDates[fileId] =
          FormatUtils.formatTimeAgo(DateTime.parse(date)).obs;
    });
  }

  void setExpireDate(String fileId, date) {
    // only for the firs time will excute this
    // but after it enter the Timer block it'll not excute this
    // -----------------------------
    expiredDates[fileId] =
        FormatUtils.formatExpireTime(DateTime.parse(date)).obs;
        if (int.parse(expiredDates[fileId]!.value) <= 0) {
      deleteDownloadableFile(fileId);
    }
    // -----------------------------
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

  Future<ConvertingFileModel?> _getConvertingFileData() async {
    if (_preferencesHelper.fetchConvertingFileData() != null) {
      convertingFile.value = (_preferencesHelper.fetchConvertingFileData())!;
    }
    return null;
  }

  void deleteDownloadableFile(String fileId) async {
    if (await _preferencesHelper.deleteDownloadableFile(fileId)) {
      final int fileIndex =
          downloadableFiles.indexWhere((file) => file.fileId == fileId);
      downloadableFiles.removeAt(fileIndex);
    } else {
      CustomeDialog.showDeleteFailedDialog();
    }
  }

  Future<String> getDownloadUrl() async {
    String jobId = _preferencesHelper.fetchJobId();
    String downloadUrl = await _fileService.getFileDownloadUrl(jobId);
    return downloadUrl;
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

  // void searchFor(String value) {
  //   searchResult.value =
  //       files.where((i) => i["fileName"].toString().contains(value)).toList();
  //   print(value);
  //   print(searchResult.length);
  // }
}
