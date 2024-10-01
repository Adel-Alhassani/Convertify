import 'package:convertify/service/init_services.dart';
import 'package:convertify/view/screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(
      const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
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
    return const ScreenUtilInit(
      designSize: Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Convertify',
        home: Homescreen(),
      ),
    );
  }
}
