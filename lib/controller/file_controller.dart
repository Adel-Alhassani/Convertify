import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class FileController extends GetxController {
  bool isFileUploaded = false;

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      isFileUploaded = true;
      update();
      print(file);
    } else {
      // User canceled the picker
    }
  }
}
