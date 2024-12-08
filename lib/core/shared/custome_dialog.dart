import 'package:convertify/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomeDialog {
  static void _showConfirmDialog(String title, String content,
      String confirmTxt, void Function() onPressed,
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

  static void _showConfirmDialogWithSpecialText(
      {required String title,
      required String content,
      required String specialText,
      required String confirmTxt,
      required void Function() onPressed,
      bool? barrierDismissible}) {
    Get.defaultDialog(
      title: title,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      barrierDismissible: barrierDismissible ?? true,
      content: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          text: "$content\n",
          style: Get.textTheme.bodyLarge,
          children: [
            TextSpan(
              text: specialText,
              style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp),
            ),
          ],
        ),
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

  static void _showConfirmDialogNoTitle(
      String content, String confirmTxt, void Function() onPressed,
      {bool? barrierDismissible}) {
    Get.defaultDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
      barrierDismissible: barrierDismissible ?? true,
      title: "",
      titlePadding: const EdgeInsets.all(0),
      content: Text(
        content,
        style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.blackColor),
      ),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 17.w),
      barrierDismissible: barrierDismissible ?? true,
      content: Text(
        content,
        style: Get.textTheme.bodyMedium!.copyWith(color: AppColor.blackColor),
      ),
      confirm: Container(
        margin: EdgeInsets.only(left: 3.w),
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
        margin: EdgeInsets.only(right: 3.w),
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

  // static showTextOnlyDialog(String title, String content,
  //     {bool? barrierDismissible}) {
  //   Get.defaultDialog(
  //     title: title,
  //     contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
  //     barrierDismissible: barrierDismissible ?? true,
  //     content: Text(
  //       content,
  //     ),
  //     titleStyle: Get.textTheme.headlineSmall!
  //         .copyWith(color: AppColor.blackColor, fontWeight: FontWeight.bold),
  //   );
  // }

  static showFormatErrorDialog() {
    _showConfirmDialog("error".tr, "format_unknown".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showUnknownErrorDialog() {
    _showConfirmDialog("error".tr, "unknown_error".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showConvertingErrorDialog() {
    _showConfirmDialog("error".tr, "coverting_error".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showDeleteFailedDialog() {
    _showConfirmDialogNoTitle("delete_failed".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showDownloadingErrorDialog() {
    _showConfirmDialog("error".tr, "downloading_error".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showSuccessFileDownloadDialog(String appDir) {
    _showConfirmDialogWithSpecialText(
        title: "donwloaded_complate".tr,
        content: "file_downloaded_successfully".tr,
        specialText: "download_dir".tr.trParams({"appDir": appDir}),
        confirmTxt: "ok".tr,
        onPressed: () {
          Get.back();
        });
  }

  static showFetchValidFormatErrorDialog() {
    _showConfirmDialog(
        "error".tr, "fetch_valid_output_formats_error".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showDownloadableFilesListLimitError() {
    _showConfirmDialog(
        "error".tr, "downloadable_files_list_limit_reached".tr, "ok".tr, () {
      Get.back();
    });
  }

  static showNoInternetConnectionDialog() {
    _showConfirmDialog(
        "no_internet_connection".tr, "check_internet_connection".tr, "ok".tr,
        () {
      Get.back();
    });
  }

  static showFileSizeLargeDialog(int limitSizeInMB) {
    _showConfirmDialog(
        "file_size_large".tr,
        "file_size_limit".trParams(({"limitSizeInMB": "$limitSizeInMB"})),
        "ok".tr, () {
      Get.back();
    });
  }
}
