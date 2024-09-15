import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final void Function() onPressed;
  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: width.w,
      height: height.h,
      elevation: 5,
      highlightElevation: 5,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onPressed,
      color: Color(0xff5F8BFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Color(0xffA1BCFF),
        ),
      ),
    );
  }
}
