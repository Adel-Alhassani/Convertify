import 'package:convertify/controller/ad_controller/banner_ad_controller.dart';
import 'package:convertify/controller/ad_controller/home_rewarded_ad_controller.dart';
import 'package:convertify/controller/config_controller.dart';
import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/constant/app_config.dart';
import 'package:convertify/core/localization/app_locale.dart';
import 'package:convertify/core/theme/app_theme.dart';
import 'package:convertify/service/file_service.dart';
import 'package:convertify/service/setting_services.dart';
import 'package:convertify/view/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

/// Registers services and controllers. Dependencies are passed in through
/// constructors, so tests can swap in fakes.
Future<void> initServices() async {
  final settings = await Get.putAsync(() => SettingServices().init());
  final prefs = settings.preferences;
  final service = FileService();

  Get.put(ConfigController(prefs), permanent: true);
  final files =
      Get.put(FilesController(prefs: prefs, service: service), permanent: true);
  Get.put(ConvertController(prefs: prefs, files: files, service: service),
      permanent: true);

  if (!AppConfig.isAdDisabled) {
    Get.put(BannerAdController("HOME_AD_BANNER_ID"), tag: "home");
    Get.put(BannerAdController("MY_FILES_AD_BANNER_ID"), tag: "files");
    Get.put(HomeRewardedAdController());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ConfigController>();
    return Obx(() {
      final arabic = config.isArabic;
      return GetMaterialApp(
        title: "Convertify",
        debugShowCheckedModeBanner: false,
        translations: AppLocale(),
        locale: config.locale.value,
        fallbackLocale: const Locale("en"),
        supportedLocales: const [Locale("en"), Locale("ar")],
        // Gives Material widgets Arabic strings and right-to-left layout.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(arabic: arabic),
        darkTheme: AppTheme.dark(arabic: arabic),
        themeMode: ThemeMode.system,
        home: const AppShell(),
      );
    });
  }
}
