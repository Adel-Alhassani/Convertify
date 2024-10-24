import 'package:convertify/core/constant/app_Images.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class FileDetails extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String fileExtension;
  final SvgPicture fileStatuIcon;
  const FileDetails({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.fileStatuIcon,
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
                Text(fileName,
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
        MaterialButton(
          padding: EdgeInsets.all(0),
          minWidth: 0,
          height: 0,
          splashColor: Colors.blue,
          onPressed: () {},
          child: fileStatuIcon,
        )
      ],
    );
  }
}
