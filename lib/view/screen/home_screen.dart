import 'dart:io';

import 'package:convertify/controller/ad_controller.dart';
import 'package:convertify/core/constant/app_Images.dart';
import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/view/widget/home_widgets/button_collection_dialog.dart';
import 'package:convertify/view/widget/home_widgets/home_background_paint.dart';
import 'package:convertify/view/widget/home_widgets/primary_button_with_loading.dart';
import 'package:convertify/core/shared/banner_ad_widget.dart';
import 'package:convertify/view/widget/home_widgets/selected_file_info.dart';
import 'package:convertify/view/widget/home_widgets/from_to.dart';
import 'package:convertify/view/widget/home_widgets/pick_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final PersistentTabController controller;
  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final FileController fileController = Get.put(FileController());
    final AdController adController = Get.put(AdController());
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: AppColor.primaryColor),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CustomPaint(
                  painter: HomeBackgroundPaint(),
                  child: Container(
                    width: 430.w,
                    height: 660.h,
                  ),
                ),
                Obx(() => Column(
                      children: [
                        PrimaryButtonWithLoading(
                            text: "convert".tr,
                            minWidth: 170.w,
                            height: 47.h,
                            disabled:
                                (fileController.outputFormat.value.isEmpty ||
                                        fileController.isFileUploading.value ||
                                        fileController.isFileConverting.value)
                                    ? true
                                    : false,
                            isLoading:
                                fileController.isFileUploading.value == true
                                    ? true
                                    : false,
                            loadingWidgetColor: AppColor.whiteColor,
                            btnColor:
                                (fileController.outputFormat.value.isEmpty ||
                                        fileController.isFileUploading.value ||
                                        fileController.isFileConverting.value)
                                    ? AppColor.secondaryColor
                                    : AppColor.primaryColor, // Use AppColor
                            textColor:
                                (fileController.outputFormat.value.isEmpty ||
                                        fileController.isFileUploading.value ||
                                        fileController.isFileConverting.value)
                                    ? AppColor.tertiaryColor
                                    : AppColor.whiteColor, // Use AppColor
                            onPressed: () async {
                              if (!await fileController.startFileUpload())
                                return;
                              if (!context.mounted) return;
                              widget.controller.jumpToTab(1);
                              await fileController.convertFile();
                            }),
                        SizedBox(
                          height: 10.h,
                        ),
                        fileController.isFileUploading.value
                            ? Column(
                                children: [
                                  Text("preparing_file".tr,
                                      style: Get.textTheme.displaySmall!
                                          .copyWith(
                                              color: AppColor.tertiaryColor)),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  LinearPercentIndicator(
                                    width: 150.0.w,
                                    lineHeight: 3.0.h,
                                    percent:
                                        fileController.uploadProgress.value,
                                    progressColor: AppColor.primaryColor,
                                    alignment: MainAxisAlignment.center,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    )),
              ],
            ),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 85.h,
                      ),
                      PickFile(
                          content: "tap_here_to_pick_file".tr,
                          onTap: () async {
                            await fileController.pickFile();
                          }),
                      SizedBox(
                        height: 8.h,
                      ),
                      SelectedFileInfo(
                          fileName: fileController.selectedFile.name ?? "",
                          fileSize: fileController.selectedFile.size ?? ""),
                      SizedBox(
                        height: 28.h,
                      ),
                      FromTo(
                        text: fileController.isFilePicked.value
                            ? fileController.selectedFile.extension!
                            : "-".tr,
                        textColor: fileController.isFilePicked.value
                            ? AppColor.whiteColor // Use AppColor
                            : AppColor.secondaryColor, // Use AppColor
                        borderColor: fileController.isFilePicked.value
                            ? AppColor.whiteColor // Use AppColor
                            : AppColor.secondaryColor, // Use AppColor
                      ),
                      SizedBox(
                        height: 9.h,
                      ),
                      fileController.isFilePicked.value
                          ? AppImages.enabledBottomArrowIcon
                          : AppImages.disabledBottomArrowIcon,
                      SizedBox(
                        height: 9.h,
                      ),
                      PrimaryButtonWithLoading(
                        text: "select_output_format".tr,
                        minWidth: 224.w,
                        height: 47.h,
                        disabled: fileController.validOutputFormats.isEmpty
                            ? true
                            : false,
                        isLoading:
                            fileController.isValidOutputFormatLoading.value
                                ? true
                                : false,
                        loadingWidgetColor: AppColor.primaryColor,
                        btnColor: fileController.validOutputFormats.isEmpty
                            ? AppColor.secondaryColor
                            : AppColor.whiteColor, // Use AppColor
                        textColor: fileController.validOutputFormats.isEmpty
                            ? AppColor.tertiaryColor
                            : AppColor.primaryColor, // Use AppColor
                        onPressed: () {
                          Get.dialog(ButtonCollectionDialog(
                              collection: fileController.validOutputFormats));
                        },
                      ),
                      SizedBox(
                        height: 9.h,
                      ),
                      fileController.outputFormat.value.isEmpty
                          ? AppImages.disabledHeadArrowIcon
                          : AppImages.enabledHeadArrowIcon,
                      SizedBox(
                        height: 9.h,
                      ),
                      FromTo(
                        text: fileController.outputFormat.value.isEmpty
                            ? "-".tr
                            : fileController.outputFormat.value,
                        textColor: fileController.outputFormat.value.isEmpty
                            ? AppColor.secondaryColor
                            : AppColor.whiteColor, // Use AppColor
                        borderColor: fileController.outputFormat.value.isEmpty
                            ? AppColor.secondaryColor
                            : AppColor.whiteColor, // Use AppColor
                      ),
                      SizedBox(
                        height: 59.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(() => adController.isAdBannerLoaded.value
                  ? Container(
                      width: adController.bannerAd!.size.width.toDouble(),
                      height: adController.bannerAd!.size.height.toDouble(),
                      child: bannerAdWidget(adController.bannerAd!))
                  : const SizedBox.shrink()),
            )
          ],
        ),
      ),
    );
  }
}
