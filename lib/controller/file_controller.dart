import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class FileController extends GetxController {
  bool isFileUploaded = false;
  // FileModel? file;
  File? file;

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print("file is: $file");
      PlatformFile fileInfo = result.files.first;
      isFileUploaded = true;
      // FileModel(name: fileInfo.name);
      update();
    } else {
      // User canceled the picker
    }
  }
}
