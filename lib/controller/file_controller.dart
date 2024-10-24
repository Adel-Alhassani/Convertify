import 'dart:convert';
import 'dart:io';

import 'package:convertify/core/enums/file_statu.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:convertify/utils/format_utils.dart';
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
  Dio dio = Dio();
  final FileService _fileService = FileService();
  final SettingServices settingServicesController = Get.find();
  RxBool isFilePicked = false.obs;
  RxBool isConverting = false.obs;
  int fileSizeLimitInMB = 30;
  RxBool isValidOutputFormatLoading = false.obs;
  RxMap<String, List<String>> validOutputFormats = <String, List<String>>{}.obs;
  RxString outputFormat = "".obs;
  RxDouble downloadProgress = 0.0.obs;
  // RxBool isDownloadComplete = false.obs;
  RxBool isFileDownloading = false.obs;
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
    // Get called when controller is created
    // print(searchResult.isEmpty);
    super.onInit();
    // removeFileDateFromSharedPref();
    // _removeAllADateFromSharedPref();
    loadDataFormSharedPref();
  }

  Future<void> loadDataFormSharedPref() async {
    print("loading data");
    await _getConvertingFileDataFromSharedPref();
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
        name = FormatUtils.formatFileName(selectedFileInfo.name);
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

  Future<bool> convertFile() async {
    bool isSuccessConversion = false;
    isConverting.value = true;
    await _setConvertingFileDataToSharedPref();
    await _getConvertingFileDataFromSharedPref();
    isSuccessConversion =
        await _fileService.convert(path!, extension!, outputFormat.value);
    _removeConvertingFileDataFromSharedPref();
    convertingFile.clear();
    await _setDownloadableFileDataToSharedPref();
    await _getDownloadableFileDataFromSharedPref();
    isConverting.value = false;
    return isSuccessConversion;
  }

  Future<void> _setConvertingFileDataToSharedPref() async {
    Map<String, String?> data = {
      "fileName": name,
      "fileSize": size,
      "fileExtension": extension,
    };
    await settingServicesController.sharedPreferences
        .setString("convertingData", jsonEncode(data));
    print("set data to sharedPref with statu converting");
  }

  Future<void> _setDownloadableFileDataToSharedPref() async {
    DateTime now = DateTime.now();
    String date =
        "${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";
    String fileName = "Convertify_$date.$outputFormat";
    String fileSize =
        FormatUtils.formatFileSizeWithUnits(await _fileService.getFileSize());
    String fileExtension = outputFormat.value;
    String fileDownloadUrl = _fileService.getDownloadUrl();
    Map<String, String> data = {
      "fileName": fileName,
      "fileSize": fileSize,
      "fileExtension": fileExtension,
      "fileDownloadUrl": fileDownloadUrl
    };
    await settingServicesController.sharedPreferences
        .setString("downloadableData", jsonEncode(data));
    print("set data to sharedPref with statu downloadable");
  }

  Future<void> _getConvertingFileDataFromSharedPref() async {
    if (settingServicesController.sharedPreferences
            .getString("convertingData") !=
        null) {
      String data = settingServicesController.sharedPreferences
          .getString("convertingData")!;
      if (data.isNotEmpty) {
        convertingFile.value = jsonDecode(data);
        print("add data form sharedPref to $convertingFile");
      } else {
        print("data of convertingFile is empty");
      }
    }
    print("data of convertingFile is null");
  }

  Future<void> _getDownloadableFileDataFromSharedPref() async {
    if (settingServicesController.sharedPreferences
            .getString("downloadableData") !=
        null) {
      String data = settingServicesController.sharedPreferences
          .getString("downloadableData")!;
      if (data.isNotEmpty) {
        downloadableFile.value = jsonDecode(data);
        print("add data form sharedPref to $downloadableFile");
      } else {
        print("data of downloadableFile is empty");
      }
    }
    print("data of downloadableFile is null");
  }

  Future<void> _removeConvertingFileDataFromSharedPref() async {
    return await settingServicesController.sharedPreferences
            .remove("convertingData")
        ? print("converting data removed")
        : print("converting data DID not removed");
  }

  Future<void> _removeDownloadableFileDataFromSharedPref() async {
    return await settingServicesController.sharedPreferences
            .remove("downloadableData")
        ? print("downloadable data removed")
        : print("downloadable data DID not removed");
  }

  Future<void> _removeAllADateFromSharedPref() async {
    return await settingServicesController.sharedPreferences.clear()
        ? print("All data removed")
        : print("All data DID not removed");
  }

  // Future<void> _addSharedPrefFileDataTo(RxMap<String, dynamic> map) async {
  //   String data = await _getFileDateFromSharedPref();
  //   if (data.isNotEmpty) {
  //     map.value = jsonDecode(data);
  //     print("add data form sharedPref to $map");
  //   } else {
  //     print("data is empty");
  //   }
  // }

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

  void downloadFile() async {
    PermissionUtils.getStoragePermission();
    String fileName = downloadableFile["fileName"];
    String fileDownloadUrl = downloadableFile["fileDownloadUrl"];
    print("in downloadFile fileName is: $fileName");
    print("in downloadFile fileDownloadUrl is: $fileDownloadUrl");
    await dio.download(
      fileDownloadUrl,
      "${await getAppDirectory()}/$fileName",
      onReceiveProgress: (count, total) {
        if (total != -1) {
          downloadProgress.value = FormatUtils.formatFileSize(count / total);
        }
      },
    );
    // await FlutterDownloader.enqueue(
    //   url: _fileService.getDownloadUrl(),
    //   savedDir: await getAppDirectory(),
    //   showNotification:
    //       true, // show download progress in status bar (for Android)
    //   openFileFromNotification: true,
    //   // saveInPublicStorage: true
    // );
  }

  // void searchFor(String value) {
  //   searchResult.value =
  //       files.where((i) => i["fileName"].toString().contains(value)).toList();
  //   print(value);
  //   print(searchResult.length);
  // }
}
