import 'package:convertify/core/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchFileBar extends StatelessWidget {
  final void Function(String) onChanged;
  const SearchFileBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 376.w,
        height: 40.h,
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
                style: BorderStyle.solid,
                width: 2.w,
                color: AppColor.secondaryColor)),
        child: TextField(
          // to ignor the search bar when tap outside the bar
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            cursorColor: AppColor.secondaryColor,
            cursorOpacityAnimates: true,
            decoration: InputDecoration(
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: AppColor.secondaryColor,
                hintText: "search_in_files".tr,
                hintStyle: Get.textTheme.bodyMedium,
                border: InputBorder.none),
            onChanged: onChanged));
  }
}
