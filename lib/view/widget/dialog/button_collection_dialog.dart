import 'package:convertify/core/constant/app_color.dart';
import 'package:convertify/controller/file_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ButtonCollectionDialog extends StatelessWidget {
  final Map<String, List<String>>? collection;
  // final void Function() onPressed;
  // final String value;

  ButtonCollectionDialog({
    super.key,
    required this.collection,
    // required this.onPressed,
    // required this.value,
  });

  final _scrollController = ScrollController();
  final FileController fileController = Get.find();

  @override
  Widget build(BuildContext context) {
    List category = collection!.keys.toList();
    return Dialog(
      child: Container(
          width: 354.w,
          height: 434.h,
          decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(23.r)),
          child: Center(
            child: Container(
                height: 397.h,
                width: 314.w,
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: WidgetStateProperty.all(2.w),
                    thumbColor: WidgetStateProperty.all(AppColor.whiteColor),
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
                        List<String>? currentCategoryValue =
                            collection![category[i]];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    color: AppColor.whiteColor,
                                    height: 1.h,
                                  ),
                                ),
                                Text(
                                  category[i],
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.whiteColor),
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    color: AppColor.whiteColor,
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
                                children: currentCategoryValue!.map((value) {
                                  return MaterialButton(
                                    minWidth: 65.w,
                                    height: 27.h,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onPressed: () {
                                      fileController
                                          .outputFormat.value = value.toString();
                                      Get.back();
                                    },
                                    color: AppColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r)),
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primaryColor,
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
