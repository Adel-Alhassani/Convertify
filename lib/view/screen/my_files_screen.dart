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
                          fileController.convertingFile["fileExtension"],
                    ),
              SizedBox(
                height: 20.h,
              ),

              Text("downloadable", style: Get.textTheme.headlineMedium),
              SizedBox(
                height: 15.h,
              ),
              fileController.downloadableFile.isEmpty
                  ? Text("No downloadable file")
                  : DownloadableFileDetails(
                      fileName: fileController.downloadableFile["fileName"],
                      fileSize: fileController.downloadableFile["fileSize"],
                      fileExtension:
                          fileController.downloadableFile["fileExtension"],
                      onPressed: () {
                        fileController.downloadFile(
                          fileController.downloadableFile["fileName"],
                          fileController.downloadableFile["fileDownloadUrl"]
                        );
                      },
                    )

              // Container(
              //     // color: Colors.amber,
              //     height: 670.w,
              //     child: fileController.files.isEmpty
              //         ? SizedBox()
              //         : ListView.builder(
              //             padding: EdgeInsets.all(0),
              //             itemCount: fileController.searchResult.isEmpty? fileController.files.length : fileController.searchResult.length,
              //             itemBuilder: (context, index) {
              //               return fileController.files.isEmpty
              //                   ? Text("no_converted_files")
              //                   : Column(
              //                       children: [
              //                         InkWell(
              //                           onTap: () {},
              //                           child: fileController.searchResult.isEmpty? FileDetails(
              //                             fileName: fileController.files[index]
              //                                 ["fileName"],
              //                             fileSize: fileController.files[index]
              //                                 ["fileSize"],
              //                             fileType: fileController.files[index]
              //                                 ["fileType"],
              //                             fileStatuIcon:
              //                                 "assets/icon/converting.svg",
              //                           ) : FileDetails(
              //                             fileName: fileController.searchResult[index]
              //                                 ["fileName"],
              //                             fileSize: fileController.searchResult[index]
              //                                 ["fileSize"],
              //                             fileType: fileController.searchResult[index]
              //                                 ["fileType"],
              //                             fileStatuIcon:
              //                                 "assets/icon/converting.svg",
              //                           ),
              //                         ),
              //                         SizedBox(
              //                           height: 24.h,
              //                         )
              //                       ],
              //                     );
              //             }),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
