import 'package:convertify/controller/file_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingServices extends GetxService {
  late SharedPreferences sharedPreferences;

  Future<SettingServices> init() async {
    await ScreenUtil.ensureScreenSize();
    dotenv.load(fileName: ".env");
    sharedPreferences = await SharedPreferences.getInstance();
    MobileAds.instance.initialize();
    return this;
  }
}
