import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SelectedFileInfo extends StatelessWidget {
  final String fileName;
  final String fileSize;
  const SelectedFileInfo({
    super.key,
    required this.fileName,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        width: 221.w,
        height: 35.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FormatUtils.formatFileName(fileName, 15),
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 13.sp,
                color: AppColor.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              fileSize,
              style: TextStyle(
                fontFamily: "inter",
                fontSize: 13.sp,
                color: AppColor.whiteColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
