import 'package:convertify/controller/file_controller.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

class InitServices extends GetxService {
  Future<InitServices> init() async {
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
    Get.put(FileController());
    print("init");
    return this;
  }
  
}
