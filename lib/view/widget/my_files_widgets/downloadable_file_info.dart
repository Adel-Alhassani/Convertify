import 'dart:ffi';

import 'package:convertify/controller/config_controller.dart';
import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/core/constant/app_Images.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/core/shared/custome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadableFileInfo extends StatelessWidget {
  final String fileId;
  final String fileName;
  final String fileSize;
  final String fileExtension;
  final String downloadUrl;
  final String convertedDate;
  final String expireDate;
  const DownloadableFileInfo({
    super.key,
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.downloadUrl,
    required this.convertedDate,
    required this.expireDate,
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
                Text("$fileSize, $convertedDate",
                    style: Get.textTheme.displaySmall),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Obx(() {
              bool isDownloading =
                  fileController.isFileDownloading[fileId]?.value ?? false;
              double downloadingProgressValue =
                  fileController.downloadProgress[fileId]?.value ?? 1.0;
              return Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircularPercentIndicator(
                      radius: 15.0.r,
                      lineWidth: 2.0.w,
                      percent: downloadingProgressValue,
                      center: isDownloading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(downloadingProgressValue * 100).toInt()}",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.extraPrimaryColor),
                                ),
                                Text(
                                  "%",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 6.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.extraPrimaryColor),
                                ),
                              ],
                            )
                          : IconButton(
                              padding: const EdgeInsets.all(0),
                              iconSize: 20.r,
                              onPressed: () {
                                fileController.downloadFile(
                                    fileId, fileName, downloadUrl);
                              },
                              icon: const Icon(
                                Icons.arrow_downward_rounded,
                                color: AppColor.extraPrimaryColor,
                              )),
                      progressColor: AppColor.extraPrimaryColor),
                  SizedBox(
                    width: 15.w,
                  ),
                  InkWell(
                    splashColor: AppColor.fourthyColor,
                    onTap: () {
                      CustomeDialog.showConfirmCancleDialog(
                          "confirm_delete".tr,
                          "confirm".tr,
                          () {
                            fileController.deleteDownloadableFile(fileId);
                            Get.back();
                          },
                          "cancel".tr,
                          () {
                            Get.back();
                          });
                    },
                    child: Icon(
                      Icons.delete,
                      color: AppColor.extraPrimaryColor,
                      size: 27.r,
                    ),
                  )
                ],
              );
            }),
            SizedBox(
              height: 5.h,
            ),
            Text(
              FormatUtils.formatExpireTimeBasedOnLanguage(expireDate),
              style: Get.textTheme.displaySmall,
            )
          ],
        )
      ],
    );
  }
}
