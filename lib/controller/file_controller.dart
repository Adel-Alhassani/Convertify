import 'dart:convert';
import 'dart:io';

import 'package:convertify/core/enums/file_statu.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/utils/generate_utils.dart';
import 'package:convertify/utils/network_utils.dart';
import 'package:convertify/utils/permission_utils.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/validator_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class FileController extends GetxController {
  final Dio _dio = Dio();
  final FileService _fileService = FileService();
  final SettingServices settingServicesController = Get.find();
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
    loadDataFormSharedPref();
  }

  Future<void> loadDataFormSharedPref() async {
    print("loading data");
    await _getConvertingFileData();
    await _getDownloadableFileDataFromSharedPref();
    print("data laoded");
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

  void setOutputFormat(String outputFormat) {
    this.outputFormat.value = outputFormat;
  }

  Future<void> convertFile() async {
    try {
      isFileUploading.value = true;
      String jobId =
          await _fileService.convert(path!, extension!, outputFormat.value);
      isFileUploading.value = false;
      if (jobId.isNotEmpty) {
        await _storeConvertingFileData(jobId);
        isFileConverting.value = true;
        await _storeDownloadableFileData(await getDownloadUrl());
        removeConvertingFileData();
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

  Future<String> _getJobId() async {
    Map<String, dynamic> convertingFileData = await _getConvertingFileData();
    String jobId = convertingFileData["jobId"];
    return jobId;
  }

  Future<String> getDownloadUrl() async {
    String jobId = await _getJobId();
    String downloadUrl = await _fileService.getFileDownloadUrl(jobId);
    if (downloadUrl.isNotEmpty) {
      return downloadUrl;
    } else {
      print("download file url is empty");
      return "";
    }
  }

  Future<void> _storeConvertingFileData(String jobId) async {
    Map<String, String?> convertingFileData = {
      "fileName": name,
      "fileSize": size,
      "fileExtension": extension,
      "jobId": jobId
    };
    convertingFile.value = Map.from(convertingFileData)..remove("jobId");
    await settingServicesController.sharedPreferences
        .setString("convertingFileData", jsonEncode(convertingFileData));
    print("set converting data to sharedPref");
  }

  Future<void> _storeDownloadableFileData(String downloadUrl) async {
    if (downloadUrl.isEmpty) {
      return;
    }
    String fileName = FormatUtils.changeFileExtension(name!, outputFormat.value);
    //     "${GenerateUtils.generateNameWithDate("Convertify")}.$outputFormat";

    String fileSize = FormatUtils.formatFileSizeWithUnits(
        await _fileService.getFileSize(downloadUrl));
    String fileExtension = outputFormat.value;
    String fileDownloadUrl = downloadUrl;
    print("----- name is $name ");
    Map<String, String> data = {
      "fileName": fileName,
      "fileSize": fileSize,
      "fileExtension": fileExtension,
      "fileDownloadUrl": fileDownloadUrl
    };
    downloadableFile.value = data;
    await settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(data));
    print("set downloadable data to sharedPref");
  }

  Future<Map<String, dynamic>> _getConvertingFileData() async {
    Map<String, dynamic> data = <String, dynamic>{};
    if (settingServicesController.sharedPreferences
            .getString("convertingFileData") !=
        null) {
      String dataJson = settingServicesController.sharedPreferences
          .getString("convertingFileData")!;
      if (dataJson.isNotEmpty) {
        data = jsonDecode(dataJson);
        return data;
      } else {
        print("data of convertingFile is empty");
        return data;
      }
    }
    print("data of convertingFile is null");
    return data;
  }

  Future<void> _getDownloadableFileDataFromSharedPref() async {
    if (settingServicesController.sharedPreferences
            .getString("downloadableData") !=
        null) {
      String data = settingServicesController.sharedPreferences
          .getString("downloadableData")!;
      if (data.isNotEmpty) {
        downloadableFile.value = jsonDecode(data);
        print("add data form sharedPref to downloadableFile");
      } else {
        print("data of downloadableFile is empty");
      }
    }
    print("data of downloadableFile is null");
  }

  Future<void> removeConvertingFileData() async {
    if (await settingServicesController.sharedPreferences
        .remove("convertingFileData")) {
      convertingFile.clear();
      print("converting data removed");
    }
    print("converting data DID not removed");
  }

  // Future<void> _removeDownloadableFileDataFromSharedPref() async {
  //   return await settingServicesController.sharedPreferences
  //           .remove("downloadableData")
  //       ? print("downloadable data removed")
  //       : print("downloadable data DID not removed");
  // }

  Future<void> _removeAllADateFromSharedPref() async {
    return await settingServicesController.sharedPreferences.clear()
        ? print("All data removed")
        : print("All data DID not removed");
  }

  Future<String> getAppDirectory() async {
    // Get the path to the public Download directory
    final directory = Directory('/storage/emulated/0/Download/Convertify');
    try {
      // Check if the directory exists; if not, create it
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Folder created at: ${directory.path}');
      }
      print(directory.path);
      return directory.path;
    } catch (e) {
      print('Error creating folder: $e');
      return '';
    }
  }

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
    final String appDir = await getAppDirectory();
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
