import 'dart:io';

import 'package:convertify/model/file_model.dart';
import 'package:convertify/service/file_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:convertify/utils/file_utils.dart';

class FileController extends GetxController {
  FileModel? file;
  bool isFileUploaded = false;
  bool isFileSizeValid = true;
  int fileSizeLimitInMB = 30;
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
        data: selectedFile,
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
}
