import 'package:convertify/data/preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Holds the app language. Arabic and English are supported; anything else
/// falls back to English.
class ConfigController extends GetxController {
  ConfigController(this._prefs);
  final PreferencesHelper _prefs;

  static const supported = ["en", "ar"];
  late final Rx<Locale> locale = Rx(_initialLocale());

  bool get isArabic => locale.value.languageCode == "ar";

  Locale _initialLocale() {
    final saved = _prefs.fetchLanguageCode();
    if (saved != null && supported.contains(saved)) return Locale(saved);
    final device = Get.deviceLocale?.languageCode;
    return Locale(device == "ar" ? "ar" : "en");
  }

  Future<void> toggleLanguage() async {
    final next = isArabic ? const Locale("en") : const Locale("ar");
    locale.value = next;
    await _prefs.storeLanguageCode(next.languageCode);
    await Get.updateLocale(next);
  }
}
