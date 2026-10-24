import 'package:convertify/controller/ad_controller/home_rewarded_ad_controller.dart';
import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/core/constant/format_info.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:convertify/view/widget/common/step_indicator.dart';
import 'package:convertify/view/widget/convert/format_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Steps 2–3: a file is picked; choose (or change) the format and convert.
class ReadyView extends StatelessWidget {
  const ReadyView({super.key});

  Future<void> _convert() async {
    final convert = Get.find<ConvertController>();
    if (Get.isRegistered<HomeRewardedAdController>()) {
      await Get.find<HomeRewardedAdController>()
          .showThen(convert.startConversion);
    } else {
      await convert.startConversion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final file = convert.selectedFile.value;
      if (file == null) return const SizedBox.shrink();
      final output = convert.outputFormat.value;
      final hasFormat = output.isNotEmpty;

      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                AppHeader(
                  trailing: TextButton(
                    onPressed: convert.reset,
                    child: Text("start_over".tr),
                  ),
                ),
                const SizedBox(height: 20),
                StepIndicator(current: convert.currentStep),
                const SizedBox(height: 22),
                Text(hasFormat ? "ready_title".tr : "choose_format_title".tr,
                    style: text.headlineSmall),
                const SizedBox(height: 6),
                Text(hasFormat ? "ready_subtitle".tr : "choose_format_subtitle".tr),
                const SizedBox(height: 20),
                AppCard(
                  radius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _FileRow(
                        label: "from".tr,
                        badge: FormatBadge(file.extension, size: 52),
                        name: file.name,
                        detail: file.size,
                        action: TextButton(
                          onPressed: () async {
                            final open = await convert.pickFile();
                            if (open) await FormatPickerSheet.show();
                          },
                          child: Text("change".tr),
                        ),
                      ),
                      _Connector(),
                      if (hasFormat)
                        _FileRow(
                          label: "to".tr,
                          badge: FormatBadge(output, size: 52),
                          name: FormatUtils.changeFileExtension(file.name, output),
                          detail: FormatInfo.descriptionKey(output)?.tr ??
                              output.toUpperCase(),
                          action: TextButton(
                            onPressed: () => FormatPickerSheet.show(context),
                            child: Text("change".tr),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: OutlinedButton.icon(
                            key: const Key("choose_format_button"),
                            onPressed: convert.isFormatsLoading.value
                                ? null
                                : () => FormatPickerSheet.show(context),
                            icon: convert.isFormatsLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.tune_rounded),
                            label: Text("choose_format".tr),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InfoNote(icon: Icons.schedule_rounded, text: "kept_24h".tr),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: FilledButton(
              key: const Key("convert_button"),
              onPressed: convert.canConvert ? _convert : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(hasFormat
                      ? "convert_to_format"
                          .trParams({"format": output.toUpperCase()})
                      : "convert".tr),
                  const SizedBox(width: 10),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.label,
    required this.badge,
    required this.name,
    required this.detail,
    required this.action,
  });

  final String label;
  final Widget badge;
  final String name;
  final String detail;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          badge,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.labelMedium!.copyWith(color: context.colors.muted)),
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall),
                Text(detail, style: text.bodySmall),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Icon(Icons.arrow_downward_rounded, color: c.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: c.border)),
      ],
    );
  }
}
