import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final double minWidth;
  final double height;
  final Color btnColor;
  final Color textColor;

  final void Function() onPressed;
  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.minWidth,
    required this.height,
    required this.onPressed,
    required this.btnColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth.w,
      height: height.h,
      elevation: 5,
      highlightElevation: 5,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onPressed,
      color: btnColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
