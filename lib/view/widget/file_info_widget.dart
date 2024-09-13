import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

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
    return SizedBox(
      width: 221.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              margin: EdgeInsets.only(right: 15.w),
              child: SvgPicture.asset(
                "icon/file_info.svg",
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                fileSize,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}
