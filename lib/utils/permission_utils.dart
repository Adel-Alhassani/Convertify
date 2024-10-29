import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static void getStoragePermission() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } catch (e) {
      print("Error while getting storage permission");
    }
  }
}
