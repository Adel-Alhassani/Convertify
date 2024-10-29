import 'dart:io';

import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:get/get.dart';

class NetworkUtils {
  static Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      CustomeDialog.showConfirmDialog(
          "no_internet_connection".tr, "check_internet_connection".tr, "ok".tr,
          () {
        Get.back();
      });
      return false;
    }
  }
}
