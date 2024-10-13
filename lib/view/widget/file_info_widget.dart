import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/view/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class FileInfo extends StatelessWidget {
  final String fileName;
  final String fileSize;
  const FileInfo({
    super.key,
    required this.fileName,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 221.w,
      height: 50.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              child: SvgPicture.asset(
                "assets/icon/file_info.svg",
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
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
          )
        ],
      ),
    );
  }
}
