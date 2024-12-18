import 'package:convertify/controller/ad_controller/my_files_banner_ad_controller.dart.dart';
import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/core/constant/app_config.dart';
import 'package:convertify/core/shared/banner_ad_widget.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/view/widget/my_files_widgets/converting_file_details.dart';
import 'package:convertify/view/widget/my_files_widgets/custom_animated_list.dart';
import 'package:convertify/view/widget/my_files_widgets/downloadable_file_info.dart';
import 'package:convertify/view/widget/my_files_widgets/search_file_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyFilesScreen extends StatefulWidget {
  const MyFilesScreen({super.key});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> {
  late final FileController fileController;
  MyFilesBannerAdController? myFilesBannerAdController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fileController = Get.find();
    if (!AppConfig.isAdDisabled) {
      myFilesBannerAdController = Get.put(MyFilesBannerAdController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: Stack(children: [
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                padding: EdgeInsets.all(0),
                children: [
                  // SizedBox(
                  //   height: 25.h,
                  // ),
                  // Text(
                  //   "my_files".tr,
                  //   style: Get.textTheme.headlineMedium!
                  //       .copyWith(fontWeight: FontWeight.w700),
                  // ),
                  SizedBox(
                    height: 55.h,
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
                          fileName:
                              fileController.convertingFile.value.fileName!,
                          fileSize:
                              fileController.convertingFile.value.fileSize!,
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
                      maxHeight:
                          myFilesBannerAdController == null ? 620.h : 550.h,
                    ),
                    child: fileController.downloadableFiles.isEmpty
                        ? Center(
                            child: Text(
                            "no_downloadable_files".tr,
                            style: Get.textTheme.bodySmall!
                                .copyWith(color: AppColor.blackSecondaryColor),
                          ))
                        : CustomAnimatedList(
                            listKey: fileController.listKey,
                            itemsLength: fileController.searchResult.isNotEmpty
                                ? fileController.searchResult.length
                                : fileController.downloadableFiles.length,
                            itemBuilder: (context, index, animation) {
                              return fileController.searchResult.isNotEmpty
                                  ? Obx(() {
                                      List<DownloadableFileModel> items =
                                          fileController.searchResult.reversed
                                              .toList();
                                      String fileId = items[index].fileId!;
                                      return FadeTransition(
                                        opacity: animation,
                                        child: Column(
                                          children: [
                                            DownloadableFileInfo(
                                              fileId: fileId,
                                              fileName: items[index].fileName!,
                                              fileSize: items[index].fileSize!,
                                              fileExtension: items[index]
                                                  .fileOutputFormat!,
                                              downloadUrl:
                                                  items[index].fileDownloadUrl!,
                                              convertedDate: fileController
                                                  .convertedDates[fileId]!
                                                  .value,
                                              expireDate: fileController
                                                  .expiredDates[fileId]!.value,
                                            ),
                                            SizedBox(
                                              height: 24.h,
                                            )
                                          ],
                                        ),
                                      );
                                    })
                                  : Obx(() {
                                      List<DownloadableFileModel> items =
                                          fileController
                                              .downloadableFiles.reversed
                                              .toList();
                                      String fileId = items[index].fileId!;
                                      return FadeTransition(
                                        opacity: animation,
                                        child: Column(
                                          children: [
                                            DownloadableFileInfo(
                                              fileId: fileId,
                                              fileName: items[index].fileName!,
                                              fileSize: items[index].fileSize!,
                                              fileExtension: items[index]
                                                  .fileOutputFormat!,
                                              downloadUrl:
                                                  items[index].fileDownloadUrl!,
                                              convertedDate: fileController
                                                  .convertedDates[fileId]!
                                                  .value,
                                              expireDate: fileController
                                                  .expiredDates[fileId]!.value,
                                            ),
                                            SizedBox(
                                              height: 24.h,
                                            )
                                          ],
                                        ),
                                      );
                                    });
                            }),
                  ),
                ],
              ),
            ),
          ),
          myFilesBannerAdController == null
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(() =>
                      myFilesBannerAdController!.isMyFilesAdBannerLoaded.value
                          ? bannerAdWidget(
                              myFilesBannerAdController!.myFilesBannerAd!)
                          : const SizedBox.shrink()),
                )
        ]),
      ),
    );
  }
}
