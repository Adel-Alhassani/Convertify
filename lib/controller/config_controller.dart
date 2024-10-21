import 'package:convertify/core/constant/app_theme.dart';
import 'package:convertify/core/localization/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigController extends GetxController {
  Locale? getLocale() {
    Locale? locale = /*Get.deviceLocale;*/ Locale("en");
    return locale;
    // if (locale!.languageCode == "ar") {
    //   return locale;
    // } else {
    //   locale = const Locale("en");
    //   return locale;
    // }
  }

  ThemeData getAppTheme() {
    // if (getLocale()!.languageCode == "ar") {
    //   return AppTheme.arabicTheme;
    // } else {
    //   return AppTheme.englishTheme;
    // }
    return AppTheme.englishTheme;
  }
}
