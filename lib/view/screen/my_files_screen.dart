import 'dart:ffi';

import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/core/constant/app_images.dart';
import 'package:convertify/core/enums/file_statu.dart';
import 'package:convertify/view/widget/converting_file_details.dart';
import 'package:convertify/view/widget/downloadable_file_details.dart';
import 'package:convertify/view/widget/complated_file_details.dart';
import 'package:convertify/view/widget/search_file_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FileController fileController = Get.find();
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
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
                // fileController.searchFor(value);
              }),
              SizedBox(
                height: 20.h,
              ),
              Text("Converting", style: Get.textTheme.headlineMedium),
              SizedBox(
                height: 15.h,
              ),
              fileController.convertingFile.isEmpty
                  ? Text("No Converting file")
                  : ConvertingFileDetails(
                      fileName: fileController.convertingFile["fileName"],
                      fileSize: fileController.convertingFile["fileSize"],
                      fileExtension:
                          fileController.convertingFile["inputFormat"],
                    ),
              SizedBox(
                height: 20.h,
              ),
              Text("downloadable", style: Get.textTheme.headlineMedium),
              SizedBox(
                height: 15.h,
              ),
              Container(
                height: 670.w,
                child: fileController.downloadableFiles.isEmpty
                    ? Text("No downloadable file")
                    : ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: fileController.searchResult.isEmpty
                            ? fileController.downloadableFiles.length
                            : fileController.searchResult.length,
                        itemBuilder: (context, index) {
                          return Obx(() => Column(
                                children: [
                                  DownloadableFileDetails(
                                    fileId: fileController.downloadableFiles[index]
                                        ["fileId"],
                                    fileName: fileController
                              .downloadableFiles[index]["fileName"],
                                    fileSize: fileController
                                        .downloadableFiles[index]["fileSize"],
                                    fileExtension:
                                        fileController.downloadableFiles[index]
                                            ["outputFormat"],
                                            downloadUrl:fileController.downloadableFiles[index]
                                            ["fileDownloadUrl"],
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  )
                                ],
                              ));
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
