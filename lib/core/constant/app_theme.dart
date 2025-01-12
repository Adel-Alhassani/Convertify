import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData arabicTheme = ThemeData(
    fontFamily: "Zain",
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22.sp,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.sp,
      ),
      bodySmall: TextStyle(
        fontSize: 15.sp,
      ),
      bodyMedium: TextStyle(
        fontSize: 17.sp,
      ),
      bodyLarge: TextStyle(
        fontSize: 20.sp,
      ),
      displaySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
    ),
  );
  static ThemeData englishTheme = ThemeData(
    fontFamily: "Inter",
    textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 18.sp,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.sp,
        ),
        bodySmall: TextStyle(
          fontSize: 14.sp,
        ),
        bodyMedium: TextStyle(
          fontSize: 15.sp,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
        ),
        displaySmall: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
  );
}
