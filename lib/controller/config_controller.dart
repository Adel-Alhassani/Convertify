import 'package:convertify/core/constant/app_theme.dart';
import 'package:convertify/core/localization/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigController extends GetxController {
  Locale? locale = Get.deviceLocale;

  ThemeData getAppTheme() {
    print(locale);
    switch (locale!.languageCode) {
      case "ar":
        print("ar");
        return AppTheme.arabicTheme;
      case "en":
        print("en");
        return AppTheme.englishTheme;
    }
    return AppTheme.englishTheme;
  }
}
