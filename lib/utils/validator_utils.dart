import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:get/get.dart';

class ValidateUtils {
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
}
