import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:get/get.dart';

class ValidatorUtils {
  static String limitFileName(String name) {
    int lengthLimit = 12;
    if (name.length <= lengthLimit) {
      return name;
    } else {
      return "${name.substring(0, lengthLimit)}...";
    }
  }

  static bool validateFileSize(int bytes, int limitSizeInMB) {
    double fileSizeInMB = bytes / (1024 * 1024);
    if (fileSizeInMB >= limitSizeInMB) {
      CustomeDialog.showConfirmDialog(
          "file_size_large".tr,
          "file_size_limit".trParams(({"limitSizeInMB": "$limitSizeInMB"})),
          "ok".tr, () {
        Get.back();
      });
      return false;
    }
    return true;
  }

  static String formatFileSize(int bytes) {
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
}
