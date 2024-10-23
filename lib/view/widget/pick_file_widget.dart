import 'package:convertify/core/constant/app_Images.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PickFile extends StatelessWidget {
  final String content;
  final void Function() onTap;
  const PickFile({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
          borderType: BorderType.RRect,
          padding: EdgeInsets.all(0),
          radius: Radius.circular(15.r),
          strokeWidth: 3.w,
          dashPattern: [9.h, 5.w],
          color: AppColor.blackColor,
          child: Container(
            decoration: BoxDecoration(
                color: Color(0xffB7CBFF),
                borderRadius: BorderRadius.all(Radius.circular(15.r))),
            height: 177.h,
            width: 221.w,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImages.addFile,
                  SizedBox(
                    height: 17.h,
                  ),
                  Text(
                    content,
                    style: Get.textTheme.bodySmall!
                        .copyWith(color: AppColor.blackColor),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
