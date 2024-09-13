import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonCollectionDialog extends StatelessWidget {
  final Map<String, List<String>?> collection;
  final void Function() onPressed;

  ButtonCollectionDialog({
    super.key,
    required this.collection,
    required this.onPressed,
  });

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
