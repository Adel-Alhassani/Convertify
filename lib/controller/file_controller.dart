import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class FileController extends GetxController {
  bool isFileUploaded = false;
  FileModel? file;

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      PlatformFile selectedFileInfo = result.files.first;
      isFileUploaded = true;
      file = FileModel(
          data: selectedFile,
          name: formatFileName(selectedFileInfo.name),
          size: formatFileSize(selectedFileInfo.size),
          extension: selectedFileInfo.extension ?? "Unknown");
      update();
    } else {
      // User canceled the picker
    }
  }
}

String formatFileName(String name) {
  int lengthLimit = 15;
  if (name.length <= lengthLimit) {
    return name;
  } else {
    return "${name.substring(0, lengthLimit)}...";
  }
}

String formatFileSize(int bytes) {
  if (bytes <= 0) return "0 B";

  const int kb = 1024;
  const int mb = 1024 * kb;
  const int gb = 1024 * mb;

  if (bytes < kb) {
    return "$bytes B";
  } else if (bytes < mb) {
    return "${(bytes / kb).toStringAsFixed(2)} KB";
  } else if (bytes < gb) {
    return "${(bytes / mb).toStringAsFixed(2)} MB";
  } else {
    return "${(bytes / gb).toStringAsFixed(2)} GB";
  }
}
