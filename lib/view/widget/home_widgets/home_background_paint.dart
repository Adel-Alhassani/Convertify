import 'package:convertify/core/constant/app_color.dart';
import 'package:flutter/material.dart';

class HomeBackgroundPaint extends CustomPainter {
   @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()..color = AppColor.whiteColor;
    canvas.drawOval(
        Rect.fromLTWH(
            -100, size.height - 30, size.width + 200, size.height / 2),
        circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}