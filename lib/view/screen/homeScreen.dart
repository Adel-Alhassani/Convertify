import 'package:convertify/controller/file_controller.dart';
import 'package:convertify/view/widget/button_collection_dialog.dart';
import 'package:convertify/view/widget/custom_primary_button.dart';
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
    FileController fileController = Get.find();
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    Map<String, List<String>?> formats = {
      "Documents": ["pdf", "doc", "docx"],
      "Images": ["pdf", "doc", "docx", "svg", "png", "jpg"],
      "Cad": [
        "pdf",
        "doc",
        "docx",
        "svg",
        "png",
      ],
      "video": ["pdf", "doc", "docx"],
      "app": ["pdf", "doc", "docx", "svg", "png", "jpg"],
      "ssss": [
        "pdf",
        "doc",
        "docx",
        "svg",
        "png",
      ],
    };

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(height: statusBarHeight, color: Color(0xff2663FF)),

                CustomPaint(
                  painter: BlueBackgroundPainter(),
                  child: Container(
                    width: 430.w,
                    height: 717.h,
                  ),
                ),
                CustomPrimaryButton(
                  text: "Convert",
                  width: 170.w,
                  height: 47.h,
                  onPressed: () {},
                )
              ],
            ),
          ),
          Container(
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
                          textStyle:
                              TextStyle(fontSize: 26.sp, color: Colors.white)),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  UploadFile(
                    iconAsset: "icon/add_file.svg",
                    content: "Click here to upload a file",
                    onTap: () async {
                      fileController.pickFile();
                    },
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  GetBuilder<FileController>(
                    builder: (controller) => fileController.isFileUploaded
                        ? FileInfo(
                            fileName: "filename.docx",
                            fileSize: "3.5 MB",
                          )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(
                    height: 28.h,
                  ),
                  FromTo(
                    text: "From",
                    textColor: Color(0xff5F8BFF),
                    borderColor: Color(0xff5F8BFF),
                  ),
                  SizedBox(
                    height: 9.h,
                  ),
                  SvgPicture.asset(
                    "icon/bottom_arrow.svg",
                    // colorFilter:
                    //     ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  SizedBox(
                    height: 9.h,
                  ),
                  CustomPrimaryButton(
                    text: "Select Output Format",
                    width: 224.w,
                    height: 47.h,
                    onPressed: () {
                      Get.dialog(ButtonCollectionDialog(
                        collection: formats,
                        onPressed: () {
                          print("object");
                        },
                      ));
                    },
                  ),
                  SizedBox(
                    height: 9.h,
                  ),
                  SvgPicture.asset(
                    "icon/head_arrow.svg",
                  ),
                  SizedBox(
                    height: 9.h,
                  ),
                  FromTo(
                    text: "To",
                    textColor: Color(0xff5F8BFF),
                    borderColor: Color(0xff5F8BFF),
                  ),
                  SizedBox(
                    height: 59.h,
                  ),
                ],
              ),
            ),
          ),
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
    paint.color = Color(0xff2663FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw white curve
    paint.color = Colors.white;
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
