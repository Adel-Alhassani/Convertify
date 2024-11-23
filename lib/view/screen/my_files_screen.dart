import 'dart:ffi';
import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/view/widget/converting_file_details.dart';
import 'package:convertify/view/widget/downloadable_file_details.dart';
import 'package:convertify/view/widget/search_file_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FileController fileController = Get.find();
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            padding: EdgeInsets.all(0),
            children: [
              SizedBox(
                height: statusBarHeight + 82.h,
              ),
              Text(
                "my_files".tr,
                style: Get.textTheme.headlineMedium!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 20.h,
              ),
              SearchFileBar(onChanged: (value) {
                fileController.searchFor(value);
              }),
              SizedBox(
                height: 20.h,
              ),
              !fileController.isFileConverting.value
                  ? Container(
                      width: 383.w,
                      height: 85.h,
                      decoration: BoxDecoration(
                          color: AppColor.fourthyColor,
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Center(
                          child: Text("no_converting_file".tr,
                              style: Get.textTheme.bodySmall!.copyWith(
                                  color: AppColor.blackSecondaryColor))),
                    )
                  : ConvertingFileDetails(
                      fileName: fileController.convertingFile.value.fileName!,
                      fileSize: fileController.convertingFile.value.fileSize!,
                      inputFormat:
                          fileController.convertingFile.value.inputFormat!,
                      outputFormat:
                          fileController.convertingFile.value.outputFormat!,
                    ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 530.h,
                ),
                child: fileController.downloadableFiles.isEmpty
                    ? Center(
                        child: Text(
                        "no_downloadable_files".tr,
                        style: Get.textTheme.bodySmall!
                            .copyWith(color: AppColor.blackSecondaryColor),
                      ))
                    : ListView.builder(
                        // reverse: true,
                        padding: const EdgeInsets.all(0),
                        itemCount: fileController.searchResult.isNotEmpty
                            ? fileController.searchResult.length
                            : fileController.downloadableFiles.length,
                        itemBuilder: (context, index) {
                          return fileController.searchResult.isNotEmpty
                              ? Obx(() {
                                  String fileId = fileController
                                      .searchResult.reversed
                                      .toList()[index]
                                      .fileId!;
                                  return Column(
                                    children: [
                                      DownloadableFileDetails(
                                        fileId: fileId,
                                        fileName: fileController
                                            .searchResult.reversed
                                            .toList()[index]
                                            .fileName!,
                                        fileSize: fileController
                                            .searchResult.reversed
                                            .toList()[index]
                                            .fileSize!,
                                        fileExtension: fileController
                                            .searchResult.reversed
                                            .toList()[index]
                                            .fileOutputFormat!,
                                        downloadUrl: fileController
                                            .searchResult.reversed
                                            .toList()[index]
                                            .fileDownloadUrl!,
                                        convertedDate: fileController
                                            .convertedDates[fileId]!.value,
                                        expireDate: fileController
                                            .expiredDates[fileId]!.value,
                                      ),
                                      SizedBox(
                                        height: 24.h,
                                      )
                                    ],
                                  );
                                })
                              : Obx(() {
                                  String fileId = fileController
                                      .downloadableFiles.reversed
                                      .toList()[index]
                                      .fileId!;
                                  return Column(
                                    children: [
                                      DownloadableFileDetails(
                                        fileId: fileId,
                                        fileName: fileController
                                            .downloadableFiles.reversed
                                            .toList()[index]
                                            .fileName!,
                                        fileSize: fileController
                                            .downloadableFiles.reversed
                                            .toList()[index]
                                            .fileSize!,
                                        fileExtension: fileController
                                            .downloadableFiles.reversed
                                            .toList()[index]
                                            .fileOutputFormat!,
                                        downloadUrl: fileController
                                            .downloadableFiles.reversed
                                            .toList()[index]
                                            .fileDownloadUrl!,
                                        convertedDate: fileController
                                            .convertedDates[fileId]!.value,
                                        expireDate: fileController
                                            .expiredDates[fileId]!.value,
                                      ),
                                      SizedBox(
                                        height: 24.h,
                                      )
                                    ],
                                  );
                                });
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
