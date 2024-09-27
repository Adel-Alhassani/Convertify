import 'package:convertify/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SuccessBottomsheet {
  static void showSuccessWithBtnBottomsheet(String textBtn,void Function()? onPressed) {
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 33.h, left: 20, right: 20, bottom: 30),
      height: 414.h,
      width: 407.w,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("icon/file_success.svg"),
          SizedBox(
            height: 29.h,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'The file has been converted successfully.\n Click ',
              style: TextStyle(fontSize: 16.sp, color: AppColor.blackColor),
              children: <TextSpan>[
                TextSpan(
                    text: '“$textBtn”',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                  text: ' to download it.',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          MaterialButton(
            splashColor: AppColor.fourthyColor,
            minWidth: 220.w,
            height: 47.h,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: onPressed,
            color: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: AppColor.primaryColor, // Set the border color
                  width: 3.0,
                ), // Set the border width
                borderRadius: BorderRadius.circular(15.r)),
            child: Text(
              "Download",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
