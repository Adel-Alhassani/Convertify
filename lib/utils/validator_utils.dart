import 'package:convertify/core/exception/file_exceptions.dart';
import 'package:convertify/core/exception/network_exceptions.dart';
import 'package:convertify/core/logger.dart';
import 'package:convertify/core/shared/custome_dialog.dart';

class ValidateUtils {
  static bool validateFileSize(int bytes, int limitSizeInMB) {
    double fileSizeInMB = bytes / (1024 * 1024);
    if (fileSizeInMB >= limitSizeInMB) {
      CustomeDialog.showFileSizeLargeDialog(limitSizeInMB);
      return false;
    }
    return true;
  }
}
