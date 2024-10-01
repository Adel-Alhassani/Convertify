import 'package:convertify/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomeDialog {
  static void showConfirmDialog(String title, String content, String confirmTxt,
      void Function() onPressed,
      {bool? barrierDismissible}) {
    Get.defaultDialog(
      title: title,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      barrierDismissible: barrierDismissible ?? true,
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
          onPressed();
        },
        child: Text(confirmTxt),
      ),
    );
  }

  static showTextOnlyDialog(String title, String content,
      {bool? barrierDismissible}) {
    Get.defaultDialog(
      title: title,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      barrierDismissible: barrierDismissible ?? true,
      content: Text(
        content,
      ),
      titleStyle: TextStyle(fontSize: 20.sp),
    );
  }
}
