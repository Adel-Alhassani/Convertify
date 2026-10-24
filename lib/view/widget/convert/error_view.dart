import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/convert/format_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A failed upload or conversion, shown in place with what happened and a
/// way forward, instead of a generic dialog.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    final text = Theme.of(context).textTheme;
    final c = context.colors;

    return Obx(() {
      final error = convert.error.value;
      final uploadFailed = convert.failedStep.value == FailedStep.upload;
      final output = convert.outputFormat.value.toUpperCase();
      final percent = (convert.uploadProgress.value * 100).round();

      final detail = uploadFailed && percent > 0
          ? "upload_stopped_at".trParams({
              "percent": "$percent",
              "sent": FormatUtils.formatFileSizeWithUnits(
                  convert.uploadedBytes.value),
              "total": convert.activeFileSize.value,
            })
          : null;

      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                const AppHeader(),
                const SizedBox(height: 28),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration:
                        BoxDecoration(color: c.dangerSoft, shape: BoxShape.circle),
                    child: Icon(Icons.error_outline_rounded,
                        size: 36, color: c.danger),
                  ),
                ),
                const SizedBox(height: 14),
                Text(error?.title ?? "error".tr,
                    style: text.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  [error?.message ?? "unknown_error".tr, "original_untouched".tr]
                      .join(" "),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppCard(
                  radius: 22,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    children: [
                      _Row(
                        failed: uploadFailed,
                        done: !uploadFailed,
                        title: uploadFailed
                            ? "stage_upload_failed".tr
                            : "stage_uploaded".tr,
                        subtitle: detail,
                        progress: uploadFailed && percent > 0
                            ? convert.uploadProgress.value
                            : null,
                      ),
                      Divider(color: c.border),
                      _Row(
                        failed: !uploadFailed,
                        title: uploadFailed
                            ? "stage_converting".trParams({"format": output})
                            : "stage_convert_failed".tr,
                      ),
                      Divider(color: c.border),
                      _Row(title: "stage_ready".tr),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (convert.canRetry) ...[
                  FilledButton.icon(
                    key: const Key("try_again_button"),
                    onPressed: convert.retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text("try_again".tr),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  onPressed: () async {
                    convert.reset();
                    final openSheet = await convert.pickFile();
                    if (openSheet) await FormatPickerSheet.show();
                  },
                  child: Text("choose_another".tr),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    this.subtitle,
    this.failed = false,
    this.done = false,
    this.progress,
  });

  final String title;
  final String? subtitle;
  final bool failed;
  final bool done;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final Widget icon = failed
        ? CircleAvatar(
            radius: 16,
            backgroundColor: c.dangerSoft,
            child: Icon(Icons.close_rounded, size: 18, color: c.danger))
        : done
            ? CircleAvatar(
                radius: 16,
                backgroundColor: c.successSoft,
                child: Icon(Icons.check_rounded, size: 18, color: c.success))
            : Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 1.5),
                ),
              );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    title,
                    style: text.titleSmall!.copyWith(
                      color: failed
                          ? c.danger
                          : done
                              ? c.ink
                              : c.muted,
                      fontWeight: failed || done ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: text.bodySmall),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  ProgressBar(
                    value: progress,
                    color: c.danger,
                    trackColor: c.dangerSoft,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
