import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FromTo extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color borderColor;
  const FromTo({
    super.key,
    required this.text,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
              color: borderColor, style: BorderStyle.solid, width: 1.w),
          // color: Colors.amber,
          borderRadius: BorderRadius.circular(8.r)),
      width: 75.w,
      height: 30.h,
      child: Text(
        text,
        style: Get.textTheme.bodyMedium!.copyWith(
          color: textColor
        ),
      ),
    );
  }
}
