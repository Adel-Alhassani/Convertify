import 'dart:ffi';
import 'package:convertify/view/widget/custom_primary_button.dart';
import 'package:convertify/view/widget/file_info_widget.dart';
import 'package:convertify/view/widget/from_to.dart';
import 'package:convertify/view/widget/upload_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFileUploaded = true;
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
          Column(
            children: [
              Container(height: statusBarHeight, color: Color(0xff2663FF)),
              SvgPicture.asset(
                "image/background.svg",
                alignment: Alignment.topCenter,
              ),
            ],
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
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  isFileUploaded
                      ? FileInfo(
                          fileName: "filename.docx",
                          fileSize: "3.5 MB",
                        )
                      : Container(),
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
                        title: "choose thejjjjhhhhhhhhhhhhh output format",
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
                    text: "From",
                    textColor: Color(0xff5F8BFF),
                    borderColor: Color(0xff5F8BFF),
                  ),
                  SizedBox(
                    height: 59.h,
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
          ),
        ],
      ),
    );
  }
}

class ButtonCollectionDialog extends StatelessWidget {
  final String title;
  final Map<String, List<String>?> collection;
  final void Function() onPressed;

  ButtonCollectionDialog(
      {super.key,
      required this.collection,
      required this.onPressed,
      required this.title});

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List category = collection.keys.toList();

    return Dialog(
      child: Container(
          width: 354.w,
          height: 434.h,
          decoration: BoxDecoration(
              color: Color(0xff2663FF),
              borderRadius: BorderRadius.circular(23.r)),
          child: Center(
            child: Container(
                height: 397.h,
                width: 314.w,
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: WidgetStateProperty.all(2.w),
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    interactive: true,
                    radius: Radius.circular(5.r),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: category.length,
                      itemBuilder: (context, i) {
                        List currentCategoryData = collection[category[i]]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    color: Colors.white,
                                    height: 1.h,
                                  ),
                                ),
                                Text(
                                  category[i],
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    color: Colors.white,
                                    height: 1.h,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7.h,
                            ),
                            Wrap(
                                spacing: 12.w,
                                runSpacing: 12.h,
                                direction: Axis.horizontal,
                                children: currentCategoryData.map((data) {
                                  return MaterialButton(
                                    minWidth: 65.w,
                                    height: 27.h,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onPressed: onPressed,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r)),
                                    child: Text(
                                      data.toString(),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2663FF),
                                      ),
                                    ),
                                  );
                                }).toList()),
                            SizedBox(
                              height: 15.h,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )),
          )),
    );
  }
}
