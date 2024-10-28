import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/core/constant/app_images.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ConvertingFileDetails extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String fileExtension;
  const ConvertingFileDetails({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                AppImages.emptyFile,
                Container(
                  width: 32.w,
                  height: 50.h,
                  // color: Colors.amber,
                  child: Center(
                    child: Text(
                      fileExtension,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          fontSize: 10.sp,
                          color: AppColor.extraPrimaryColor),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(FormatUtils.formatFileName(fileName, 20),
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    )),
                Text(fileSize,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    )),
              ],
            ),
          ],
        ),
        AppImages.converting,
      ],
    );
  }
}
