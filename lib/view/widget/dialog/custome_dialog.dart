import 'package:convertify/core/constant/app_color.dart';
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
        style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.blackColor),
      ),
      titleStyle: Get.textTheme.bodyLarge!
          .copyWith(color: AppColor.blackColor, fontWeight: FontWeight.bold),
      confirm: MaterialButton(
        minWidth: 80.w,
        height: 30.h,
        color: AppColor.primaryColor,
        textColor: AppColor.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        onPressed: () {
          onPressed();
        },
        child: Text(
          confirmTxt,
          style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.whiteColor),
        ),
      ),
    );
  }

  static void showConfirmDialogNoTitle(
      String content, String confirmTxt, void Function() onPressed,
      {bool? barrierDismissible}) {
    Get.defaultDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
      barrierDismissible: barrierDismissible ?? true,
      title: "",
      content: Text(
        content,
        style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.blackColor),
      ),
      titleStyle: Get.textTheme.bodyLarge!
          .copyWith(color: AppColor.blackColor, fontWeight: FontWeight.bold),
      confirm: MaterialButton(
        minWidth: 80.w,
        height: 30.h,
        color: AppColor.primaryColor,
        textColor: AppColor.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        onPressed: () {
          onPressed();
        },
        child: Text(
          confirmTxt,
          style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.whiteColor),
        ),
      ),
    );
  }

  static void showConfirmCancleDialog(
      String content,
      String confirmTxt,
      void Function() onConfirmPressed,
      String cancelTxt,
      void Function() onCancelpressed,
      {bool? barrierDismissible}) {
    Get.defaultDialog(
      title: "",
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      barrierDismissible: barrierDismissible ?? true,
      content: Text(
        content,
        style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.blackColor),
      ),
      titleStyle: Get.textTheme.bodyLarge!
          .copyWith(color: AppColor.blackColor, fontWeight: FontWeight.bold),
      confirm: Container(
        margin: EdgeInsets.only(left: 5.w),
        child: MaterialButton(
          minWidth: 80.w,
          height: 30.h,
          color: AppColor.primaryColor,
          textColor: AppColor.whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          onPressed: () {
            onConfirmPressed();
          },
          child: Text(
            confirmTxt,
            style:
                Get.textTheme.bodyMedium!.copyWith(color: AppColor.whiteColor),
          ),
        ),
      ),
      cancel: Container(
        margin: EdgeInsets.only(right: 5.w),
        child: MaterialButton(
          minWidth: 80.w,
          height: 30.h,
          color: AppColor.primaryColor,
          textColor: AppColor.whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          onPressed: () {
            onCancelpressed();
          },
          child: Text(
            cancelTxt,
            style:
                Get.textTheme.bodyMedium!.copyWith(color: AppColor.whiteColor),
          ),
        ),
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
      titleStyle: Get.textTheme.headlineSmall!
          .copyWith(color: AppColor.blackColor, fontWeight: FontWeight.bold),
    );
  }
}
