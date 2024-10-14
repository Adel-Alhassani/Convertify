import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/network_service.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileController extends GetxController {
  FileModel file = FileModel();

  final FileService _fileService = FileService();
  final FileUtils fileUtils = FileUtils();
  RxBool isFilePicked = false.obs;
  RxBool isConverting = false.obs;
  int fileSizeLimitInMB = 30;
  RxBool isValidOutputFormatLoading = false.obs;
  RxMap<String, List<String>> validOutputFormats = <String, List<String>>{}.obs;
  RxString _outputFormat = "".obs;
 

  pickFile() async {
    _outputFormat.value = "";
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
      
      file.path = selectedFile.path;
      file.name = fileUtils.limitFileName(selectedFileInfo.name);
      file.size = fileUtils.formatFileSize(selectedFileInfo.size);
      file.extension = selectedFileInfo.extension;

      isValidOutputFormatLoading.value = true;
      validOutputFormats.value = await _fileService
          .getValidOutputFormatsOf("${selectedFileInfo.extension}");
      isValidOutputFormatLoading.value = false;
   
      isFilePicked.value = true;
    } else {
      
    }
  }

  void setOutputFormat(String outputFormat) {
    _outputFormat.value = outputFormat;
  }

  String getOutputFormat() {
    return _outputFormat.value;
  }

  Future<String> createPublicFolder(String folderName) async {
    // Get the path to the public Documents directory
    final directory = Directory('/storage/emulated/0/Documents/$folderName');

    try {
      // Check if the directory exists; if not, create it
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Folder created at: ${directory.path}');
      }
      return directory.path;
    } catch (e) {
      print('Error creating folder: $e');
      return '';
    }
  }

  Future<bool> convertFile() async {
    isConverting.value = true;
    bool isSuccessConversion = false;
    isSuccessConversion = await _fileService.convert(
        file.path!, file.extension!, getOutputFormat());
    isConverting.value = false;
    return isSuccessConversion;
  }

  void downloadFile() async {
    final taskId = await FlutterDownloader.enqueue(
        url: _fileService.getDownloadUrl(),
        // 'https://file-examples.com/storage/fe58a1f07d66f447a9512f1/2017/04/file_example_MP4_1920_18MG.mp4',
        savedDir: await createPublicFolder("convertify"),
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification: true,
        // fileName: file.name
        saveInPublicStorage: true);
  }
}
