import 'package:convertify/controller/config_controller.dart';
import 'package:convertify/core/constant/app_theme.dart';
import 'package:convertify/core/localization/app_locale.dart';
import 'package:convertify/service/init_services.dart';
import 'package:convertify/view/screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

Future initServices() async {
  await Get.putAsync(
    () => InitServices().init(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ConfigController configController = Get.put(ConfigController());
    return ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          locale: configController.locale,
          theme: configController.getAppTheme(),
          translations: AppLocale(),
          debugShowCheckedModeBanner: false,
          home: child,
        ),
        child: const Homescreen(),);
  }
}
