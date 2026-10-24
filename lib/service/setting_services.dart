import 'package:convertify/core/constant/app_config.dart';
import 'package:convertify/data/preferences_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide services, initialised once before runApp.
class SettingServices extends GetxService {
  late final SharedPreferences sharedPreferences;
  late final PreferencesHelper preferences;

  Future<SettingServices> init() async {
    // Must be awaited: FileService reads the API key from dotenv.
    await dotenv.load(fileName: ".env");
    sharedPreferences = await SharedPreferences.getInstance();
    preferences = PreferencesHelper(sharedPreferences);
    if (!AppConfig.isAdDisabled) {
      await MobileAds.instance.initialize();
    }
    return this;
  }
}
