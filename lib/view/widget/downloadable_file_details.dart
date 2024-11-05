import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/core/constant/app_Images.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadableFileDetails extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String fileExtension;
  final String downloadUrl;
  const DownloadableFileDetails({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    FileController fileController = Get.find();
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
        Obx(() {
           bool isDownloading =
              fileController.isFileDownloading[fileName]?.value ?? false;
          double downloadingProgressValue =
              fileController.downloadProgress[fileName]?.value ?? 1.0;
          return CircularPercentIndicator(
              radius: 18.0.r,
              lineWidth: 2.0.w,
              percent:  downloadingProgressValue,
              center: isDownloading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(downloadingProgressValue * 100).toInt()}",
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.extraPrimaryColor),
                        ),
                        Text(
                          "%",
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.extraPrimaryColor),
                        ),
                      ],
                    )
                  : IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 22.r,
                      onPressed: () {
                        fileController.downloadFile(
                            fileName, downloadUrl);
                      },
                      icon: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColor.extraPrimaryColor,
                      )),
              progressColor: AppColor.extraPrimaryColor);
        })
      ],
    );
  }
}
