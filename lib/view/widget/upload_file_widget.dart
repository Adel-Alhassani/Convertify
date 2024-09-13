import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class UploadFile extends StatelessWidget {
  final String iconAsset;
  final String content;
  const UploadFile({
    super.key,
    required this.iconAsset,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: DottedBorder(
          borderType: BorderType.RRect,
          padding: EdgeInsets.all(0),
          radius: Radius.circular(15.r),
          strokeWidth: 3.w,
          dashPattern: [9.h, 5.w],
          color: Colors.black,
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
                  SvgPicture.asset(
                    "icon/add_file.svg",
                    height: 65.h,
                    width: 65.w,
                  ),
                  SizedBox(
                    height: 17.h,
                  ),
                  Text(
                    content,
                  )
                ],
              ),
            ),
          )),
    );
  }
}
