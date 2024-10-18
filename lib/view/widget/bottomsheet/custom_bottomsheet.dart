import 'package:convertify/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomBottomsheet {
  static void showSuccessWithBtnBottomsheet(
      firstText, String span, secondText, btnText, void Function()? onPressed) {
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 33.h, left: 20, right: 20, bottom: 30),
      height: 530.h,
      width: 410.w,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/icon/file_success.svg"),
          SizedBox(
            height: 29.h,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: firstText,
              style: Get.textTheme.bodyLarge,
              children: <TextSpan>[
                TextSpan(
                  text: span,
                  style: Get.textTheme.bodyLarge!.copyWith(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: secondText,
                  style: Get.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          MaterialButton(
            splashColor: AppColor.fourthyColor,
            minWidth: 180.w,
            height: 47.h,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: onPressed,
            color: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: AppColor.primaryColor, // Set the border color
                  width: 3.0,
                ), // Set the border width
                borderRadius: BorderRadius.circular(15.r)),
            child: Text(
              btnText,
              style: Get.textTheme.headlineMedium!.copyWith(
                  color: AppColor.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ));
  }

  static void showLoadingBottomsheet() {
    Get.bottomSheet(
        isDismissible: false,
        Container(
            padding:
                EdgeInsets.only(top: 33.h, left: 20, right: 20, bottom: 30),
            height: 430.h,
            width: 410.w,
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Center(
              child: LoadingAnimationWidget.waveDots(
                  color: AppColor.primaryColor, size: 50.w),
            )));
  }
}
