import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/core/constant/app_images.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConvertingFileDetails extends StatefulWidget {
  final String fileName;
  final String fileSize;
  final String inputFormat;
  final String outputFormat;
  const ConvertingFileDetails({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.inputFormat,
    required this.outputFormat,
  });

  @override
  State<ConvertingFileDetails> createState() => _ConvertingFileDetailsState();
}

class _ConvertingFileDetailsState extends State<ConvertingFileDetails>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<Alignment> _leftAlignmentAnimation;
  late Animation<Alignment> _rightAlignmenttAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _leftAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.centerLeft, end: Alignment.center),
          weight: 1),
    ]).animate(_animationController);
    _rightAlignmenttAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween<Alignment>(
              begin: Alignment.center, end: Alignment.centerRight),
          weight: 1),
    ]).animate(_animationController);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          width: 383.w,
          height: 85.h,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.tertiaryColor,
                  AppColor.fourthyColor,
                  AppColor.tertiaryColor,
                ],
                begin: _leftAlignmentAnimation.value,
                end: _rightAlignmenttAnimation.value,
              ),
              borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(FormatUtils.formatFileName(widget.fileName, 20),
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          )),
                      Text(widget.fileSize,
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Text(widget.inputFormat,
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w900,
                              fontSize: 10.sp,
                              color: AppColor.primaryColor)),
                      SizedBox(
                        width: 3.w,
                      ),
                      const Icon(
                        Icons.arrow_right,
                        size: 22,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(
                        width: 3.w,
                      ),
                      Text(widget.outputFormat,
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w900,
                              fontSize: 10.sp,
                              color: AppColor.primaryColor)),
                    ],
                  )
                ],
              ),
              RotationTransition(
                turns: _rotationController,
                child: AppImages.converting,
              ),
            ],
          ),
        );
      },
    );
  }
}
