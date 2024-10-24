import 'package:convertify/controller/file_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingServices extends GetxService {
  late SharedPreferences sharedPreferences;
  
  Future<SettingServices> init() async {
    dotenv.load(fileName: ".env");
    sharedPreferences = await SharedPreferences.getInstance();
    await FlutterDownloader.initialize(
        debug:
            true, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl:
            true // option: set to false to disable working with http links (default: false)
        );
    return this;
  }
}
