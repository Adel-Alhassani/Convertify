import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The running conversion, pinned at the top of the Files tab.
class InProgressCard extends StatelessWidget {
  const InProgressCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final uploading = convert.stage.value == ConvertStage.uploading;
      final percent = (convert.uploadProgress.value * 100).round();
      final arrow = Directionality.of(context) == TextDirection.rtl ? "←" : "→";
      return Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.primaryBorder, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    FormatBadge(convert.activeInputFormat.value),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${convert.activeFileName.value} $arrow ${convert.outputFormat.value.toUpperCase()}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            uploading
                                ? "uploading_percent"
                                    .trParams({"percent": "$percent"})
                                : "converting_short".tr,
                            style: text.bodySmall!.copyWith(
                                color: c.primaryInk,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    TintedIconButton(
                      icon: Icons.close_rounded,
                      tooltip: "cancel_conversion".tr,
                      primary: false,
                      onPressed: convert.cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBar(
                    value: uploading ? convert.uploadProgress.value : null),
              ],
            ),
          ),
        ),
      );
    });
  }
}
