import 'package:convertify/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PrimaryButtonWithLoading extends StatelessWidget {
  final String text;
  final double minWidth;
  final double height;
  final Color btnColor;
  final Color textColor;
  final bool isLoading;
  final bool disabled;

  final void Function() onPressed;
  const PrimaryButtonWithLoading({
    super.key,
    required this.text,
    required this.minWidth,
    required this.height,
    required this.onPressed,
    required this.btnColor,
    required this.textColor,
    required this.isLoading, required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: MaterialButton(
        minWidth: minWidth.w,
        height: height.h,
        elevation: 5,
        highlightElevation: 5,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onPressed,
        color: btnColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: isLoading
            ? LoadingAnimationWidget.waveDots(
                color: AppColor.primaryColor, size: 25.w)
            : Text(
                text,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
