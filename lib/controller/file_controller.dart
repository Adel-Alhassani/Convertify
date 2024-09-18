import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/file_utils.dart';

class FileController extends GetxController {
  bool isFileUploaded = false;
  bool isFileSizeValid = true;
  int fileSizeLimitInMB = 30;
  FileModel? file;

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
      file = FileModel(
          data: selectedFile,
          name: FileUtils.limitFileName(selectedFileInfo.name),
          size: FileUtils.formatFileSize(selectedFileInfo.size),
          extension: selectedFileInfo.extension ?? "Unknown");
      update();
    } else {
      // User canceled the picker
    }
  }
}
