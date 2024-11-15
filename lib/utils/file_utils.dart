import 'dart:io';

import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:file_picker/file_picker.dart';

class FileUtils {
  static Future<PlatformFile> pickFile() async {
    PlatformFile selectedFile;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) throw NullPickResultException();
      selectedFile = result.files.single;
      return selectedFile;
    } on NullPickResultException catch (e) {
      logger.i(e);
      rethrow;
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
