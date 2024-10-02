import 'dart:io';

import 'package:convertify/constant/color.dart';
import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/controller/network_controller.dart';
import 'package:convertify/view/widget/bottomsheet/success_bottomsheet.dart';
import 'package:convertify/view/widget/dialog/button_collection_dialog.dart';
import 'package:convertify/view/widget/button/primary_button_with_loading.dart';
import 'package:convertify/view/widget/dialog/custome_dialog.dart';
import 'package:convertify/view/widget/file_info_widget.dart';
import 'package:convertify/view/widget/from_to.dart';
import 'package:convertify/view/widget/upload_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkController networkController = Get.put(NetworkController());
    final FileController fileController = Get.put(FileController());
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColor.whiteColor, // Use AppColor
            child: Column(
              children: [
                Container(
                    height: statusBarHeight,
                    color: AppColor.primaryColor), // Use AppColor
                CustomPaint(
                  painter: BlueBackgroundPainter(),
                  child: Container(
                    width: 430.w,
                    height: 717.h,
                  ),
                ),
                Obx(() => PrimaryButtonWithLoading(
                    text: "Convert",
                    minWidth: 170.w,
                    height: 47.h,
                    disabled:
                        fileController.getOutputFormat().isEmpty ? true : false,
                    isLoading: fileController.isConverting.value ? true : false,
                    loadingWidgetColor: AppColor.whiteColor,
                    btnColor: fileController.getOutputFormat().isEmpty
                        ? AppColor.secondaryColor
                        : AppColor.primaryColor, // Use AppColor
                    textColor: fileController.getOutputFormat().isEmpty
                        ? AppColor.tertiaryColor
                        : AppColor.whiteColor, // Use AppColor
                    onPressed: () async {
                      await fileController.convertFile();
                      SuccessBottomsheet.showSuccessWithBtnBottomsheet(
                        "Download",
                        () {
                          fileController.downloadFile();
                          Get.back();
                        },
                      );
                    }))
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 65.h,
                    ),
                    Container(
                      child: Text(
                        "support nearly all documents and images formats",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manjari(
                          textStyle: TextStyle(
                            fontSize: 26.sp,
                            color: AppColor.whiteColor, // Use AppColor
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    UploadFile(
                        iconAsset: "icon/add_file.svg",
                        content: "Click here to upload a file",
                        onTap: () async {
                          await fileController.pickFile();
                        }),
                    SizedBox(
                      height: 8.h,
                    ),
                    fileController.isFilePicked.value
                        ? FileInfo(
                            fileName: fileController.file!.name,
                            fileSize: fileController.file!.size)
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 28.h,
                    ),
                    FromTo(
                      text: fileController.isFilePicked.value
                          ? fileController.file!.extension
                          : "From",
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
                        ? SvgPicture.asset(
                            "icon/enabled/enabled_bottom_arrow.svg")
                        : SvgPicture.asset(
                            "icon/disabled/disabled_bottom_arrow.svg"),
                    SizedBox(
                      height: 9.h,
                    ),
                    PrimaryButtonWithLoading(
                      text: "Select Output Format",
                      minWidth: 224.w,
                      height: 47.h,
                      disabled: fileController.validOutputFormats.isEmpty
                          ? true
                          : false,
                      isLoading: fileController.isValidOutputFormatLoading.value
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
                    fileController.getOutputFormat().isEmpty
                        ? SvgPicture.asset(
                            "icon/disabled/disabled_head_arrow.svg")
                        : SvgPicture.asset(
                            "icon/enabled/enabled_head_arrow.svg"),
                    SizedBox(
                      height: 9.h,
                    ),
                    FromTo(
                      text: fileController.getOutputFormat().isEmpty
                          ? "To"
                          : fileController.getOutputFormat(),
                      textColor: fileController.getOutputFormat().isEmpty
                          ? AppColor.secondaryColor
                          : AppColor.whiteColor, // Use AppColor
                      borderColor: fileController.getOutputFormat().isEmpty
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
          )
        ],
      ),
    );
  }
}

class BlueBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw blue background
    paint.color = AppColor.primaryColor; // Use AppColor
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw white curve
    paint.color = AppColor.whiteColor; // Use AppColor
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 80,
      size.width,
      size.height,
    );
    path.lineTo(
        size.width, size.height); // Ensure this point is included in the path
    path.lineTo(0, size.height); // Connect back to the start point
    path.close(); // Close the path to ensure it's a complete shape

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
