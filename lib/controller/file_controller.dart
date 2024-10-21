import 'dart:io';

import 'package:convertify/service/file_service.dart';
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
  RxList files = [
    {
      "fileName": "Convertify_20241122562.docx",
      "fileSize": "3.56 MB",
      "fileType": "DOCX",
      "fileStatu": "converting",
    },
    {
      "fileName": "Convertify_hhhhhh.docx",
      "fileSize": "7.56 MB",
      "fileType": "PDF",
      "fileStatu": "downloadable",
    },
    {
      "fileName": "Convertify_aaaa62.docx",
      "fileSize": "3.56 MB",
      "fileType": "PNG",
      "fileStatu": "complate",
    },
  ].obs;
  RxList searchResult = <Map<String, String>>[].obs;

  @override
  void onInit() {
    // Get called when controller is created
    print(searchResult.isEmpty);
    super.onInit();
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
    isConverting.value = true;
    bool isSuccessConversion = false;
    isSuccessConversion =
        await _fileService.convert(path!, extension!, outputFormat.value);
    isConverting.value = false;
    return isSuccessConversion;
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

  void downloadFile() async {
    PermissionUtils.getStoragePermission();
    DateTime now = DateTime.now();
    String date =
        "${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}";
    await dio.download(
      _fileService.getDownloadUrl(),
      "${await getAppDirectory()}/Convertify_$date.$outputFormat",
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

  void searchFor(String value) {
    searchResult.value =
        files.where((i) => i["fileName"].toString().contains(value)).toList();
    print(value);
    print(searchResult.length);
  }
}
