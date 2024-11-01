import 'dart:convert';
import 'dart:io';

import 'package:convertify/core/enums/file_statu.dart';
import 'package:convertify/data/preferences_helper.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:convertify/utils/network_utils.dart';
import 'package:convertify/utils/permission_utils.dart';
import 'package:convertify/utils/storage_utils.dart';
import 'package:convertify/view/screen/my_files_screen.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/validator_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class FileController extends GetxController {
  final Dio _dio = Dio();
  final FileService _fileService = FileService();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  RxBool isFilePicked = false.obs;
  RxBool isFileConverting = false.obs;
  RxBool isFileUploading = false.obs;
  RxBool isFileDownloading = false.obs;
  RxBool isValidOutputFormatLoading = false.obs;
  int fileSizeLimitInMB = 30;
  RxMap<String, List<String>> validOutputFormats = <String, List<String>>{}.obs;
  RxString outputFormat = "".obs;
  RxDouble downloadProgress = 0.0.obs;
  String? path;
  String? name;
  String? size;
  String? extension;
  RxMap<String, dynamic> convertingFile = <String, dynamic>{}.obs;
  RxMap<String, dynamic> downloadableFile = <String, dynamic>{}.obs;
  RxMap<String, String> files = <String, String>{}.obs;
  RxList searchResult = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _removeAllADateFromSharedPref();
    loadData();
  }

  void loadData() async {
    print("loading data");
    await _loadConvertingFileData();
    await _loadDownloadableFileData();
    print("data laoded");
  }

  Future<void> _loadConvertingFileData() async {
    Map<String, dynamic> data =
        await _preferencesHelper.fetchConvertingFileData();
    if (data.isNotEmpty) {
      _getConvertingFileData();
      isFileConverting.value = true;
      String fileDownloadUrl = await getDownloadUrl();
      String fileSize = FormatUtils.formatFileSizeWithUnits(
          await _fileService.getFileSize(fileDownloadUrl));
      await _preferencesHelper.storeDownloadableFileData(
          fileSize, fileDownloadUrl);
      _preferencesHelper.removeConvertingFileData();
      _clearConvertingFileMap();
      isFileConverting.value = false;
    }
  }

  Future<void> _loadDownloadableFileData() async {
    Map<String, dynamic> data =
        await _preferencesHelper.fetchDownloadableFileData();
    if (data.isNotEmpty) {
      _getDownloadableFileData();
    }
  }

  pickFile() async {
    try {
      if (!await NetworkUtils.checkInternet()) {
        return;
      }
      outputFormat.value = "";
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File selectedFile = File(result.files.single.path!);
        PlatformFile selectedFileInfo = result.files.first;
        if (selectedFileInfo.extension == null) {
          CustomeDialog.showConfirmDialog(
              "error".tr, "format_unknown".tr, "ok".tr, () {
            Get.back();
          });
        }
        path = selectedFile.path;
        name = selectedFileInfo.name;
        size = FormatUtils.formatFileSizeWithUnits(selectedFileInfo.size);
        extension = selectedFileInfo.extension;
        isValidOutputFormatLoading.value = true;
        validOutputFormats.value = await _fileService
            .getValidOutputFormatsOf("${selectedFileInfo.extension}");
        isValidOutputFormatLoading.value = false;
        isFilePicked.value = true;
      } else {}
    } catch (e) {
      print("Error when trying to pick a file: $e");
      CustomeDialog.showConfirmDialog("error".tr, "unknown_error".tr, "ok".tr,
          () {
        Get.back();
      });
      return;
    }
  }

  void pushToMyFilesScreen(){
        

  }

  Future<void> startFileUpload()async{
    isFileUploading.value = true;
      await _fileService.creatJob(extension!, outputFormat.value);
      await _fileService.uploadFile(path!);
      isFileUploading.value = false;
  }

  Future<void> convertFile() async {
    try {
      String jobId = _fileService.getJobId();
      if (jobId.isNotEmpty) {
        await _preferencesHelper.storeConvertingFileData(
            name!, size!, extension!, outputFormat.value, jobId);
        _getConvertingFileData();
        isFileConverting.value = true;
        String fileDownloadUrl = await getDownloadUrl();
        String fileSize = FormatUtils.formatFileSizeWithUnits(
            await _fileService.getFileSize(fileDownloadUrl));
        await _preferencesHelper.storeDownloadableFileData(
            fileSize, fileDownloadUrl);
        _getDownloadableFileData();
        _preferencesHelper.removeConvertingFileData();
        _clearConvertingFileMap();
        isFileConverting.value = false;
      } else {
        print("jobId is empty");
        CustomeDialog.showConfirmDialog(
            "error".tr, "coverting_error".tr, "ok".tr, () {
          Get.back();
        });
      }
    } catch (e) {
      print("Error while converting $e");
      CustomeDialog.showConfirmDialog("error".tr, "coverting_error".tr, "ok".tr,
          () {
        Get.back();
      });
    }
  }

  void _getConvertingFileData() async {
    convertingFile.value =
        Map.from(await _preferencesHelper.fetchConvertingFileData())
          ..remove("outputFormat")
          ..remove("jobId");
  }

  void _clearConvertingFileMap() {
    convertingFile.clear();
  }

  void _getDownloadableFileData() async {
    downloadableFile.value =
        Map.from(await _preferencesHelper.fetchDownloadableFileData());
  }

  Future<String> getDownloadUrl() async {
    String jobId = await _preferencesHelper.fetchJobId();
    String downloadUrl = await _fileService.getFileDownloadUrl(jobId);
    if (downloadUrl.isNotEmpty) {
      return downloadUrl;
    } else {
      print("download file url is empty");
      return "";
    }
  }

  // Future<void> _removeDownloadableFileDataFromSharedPref() async {
  //   return await settingServicesController.sharedPreferences
  //           .remove("downloadableData")
  //       ? print("downloadable data removed")
  //       : print("downloadable data DID not removed");
  // }

  Future<bool> isFileAlreadyDownloaded(String filName, String directory) async {
    if (directory.isNotEmpty) {
      final String filePath = "$directory/$filName";
      return await File(filePath).exists();
    }
    print("*** directory is empty");
    return false;
  }

  void downloadFile(String fileName, String downloadUrl) async {
    if (!await NetworkUtils.checkInternet()) {
      return;
    }
    PermissionUtils.getStoragePermission();
    final String fileDownloadUrl = downloadUrl;
    final String appDir = await StorageUtils.getAppDirectory();
    print("in downloadFile fileName is: $fileName");
    print("fileDownloadUrl is: $fileDownloadUrl".substring(0, 35));
    isFileDownloading.value = true;
    try {
      await _dio.download(
        fileDownloadUrl,
        "$appDir/$fileName",
        onReceiveProgress: (count, total) {
          if (total != -1) {
            downloadProgress.value = FormatUtils.formatFileSize(count / total);
          }
        },
      );
    } catch (e) {
      print("Error while downloading the file $e");
      CustomeDialog.showConfirmDialog(
          "error".tr, "downloading_error".tr, "ok".tr, () {
        Get.back();
      });
      return;
    } finally {
      isFileDownloading.value = false;
    }
    CustomeDialog.showConfirmDialog(
        "donwloaded_complate".tr,
        "file_downloaded_successfully".trParams(({"appDir": appDir})),
        "ok".tr, () {
      Get.back();
    });
  }

  // void searchFor(String value) {
  //   searchResult.value =
  //       files.where((i) => i["fileName"].toString().contains(value)).toList();
  //   print(value);
  //   print(searchResult.length);
  // }
}
