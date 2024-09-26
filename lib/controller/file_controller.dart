import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileController extends GetxController {
  FileModel? file;
  bool isFileUploaded = false;
  bool isFileSizeValid = true;
  int fileSizeLimitInMB = 30;
  bool isConverting = false;
  RxBool isValidOutputFormatLoading = false.obs;
  Map<String, List<String>> validOutputFormats = {};
  String _outputFormat = "";

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      PlatformFile selectedFileInfo = result.files.first;
      if (!FileUtils.validateFileSize(
          selectedFileInfo.size, fileSizeLimitInMB)) {
        return;
      }
      isFileUploaded = true;
      isValidOutputFormatLoading.value = true;
      _outputFormat = "";
      validOutputFormats = await FileService.getValidOutputFormatsOf(
          "${selectedFileInfo.extension}");
      isValidOutputFormatLoading.value = false;
      file = FileModel(
        path: selectedFile.path,
        name: FileUtils.limitFileName(selectedFileInfo.name),
        size: FileUtils.formatFileSize(selectedFileInfo.size),
        extension: selectedFileInfo.extension ?? "Unknown",
      );

      print(validOutputFormats);
      update();
    } else {
      // User canceled the picker
    }
  }

  void setOutputFormat(String outputFormat) {
    _outputFormat = outputFormat;
    update();
  }

  String getOutputFormat() {
    return _outputFormat;
  }

  Future<String> createPublicFolder(String folderName) async {
    // Get the path to the public Documents directory
    final directory = Directory('/storage/emulated/0/Documents/$folderName');

    try {
      // Check if the directory exists; if not, create it
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('Folder created at: ${directory.path}');
      } else {
        print('Folder already exists at: ${directory.path}');
      }
      return directory.path;
    } catch (e) {
      print('Error creating folder: $e');
      return '';
    }
  }

  Future<String> getDownloadUrl() async {
    isConverting = true;
    update();
    String downloadUrl = await FileService.convert(
        file!.path, file!.extension, getOutputFormat());
    isConverting = false;
    update();
    return downloadUrl;
  }

  void download() async {
    final taskId = await FlutterDownloader.enqueue(
        url: await getDownloadUrl(),
        // 'https://file-examples.com/storage/fe58a1f07d66f447a9512f1/2017/04/file_example_MP4_1920_18MG.mp4',
        savedDir: await createPublicFolder("convertify"),
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification: true,
        // fileName: file.name
        saveInPublicStorage: true);
  }
}
