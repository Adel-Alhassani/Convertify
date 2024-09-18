import 'package:convertify/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ErrorDialog {
  static void showConfirmErrorDialog (String title, String content) {
    Get.defaultDialog(
      title: title,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      content: Text(
        content,
      ),
      titleStyle: TextStyle(fontSize: 20.sp),
      confirm: MaterialButton(
        minWidth: 80.w,
        height: 30.h,
        color: AppColor.primaryColor,
        textColor: AppColor.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        onPressed: () {
          Get.back(); // Closes the dialog
        },
        child: Text("ok"),
      ),
    );
  }
}