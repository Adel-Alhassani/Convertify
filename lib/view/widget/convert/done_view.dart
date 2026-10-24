import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The result: open or share — right where the user is. It is copied into the
/// user's folder in the background; the bar shows that download.
class DoneView extends StatelessWidget {
  const DoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    final files = Get.find<FilesController>();
    final text = Theme.of(context).textTheme;
    final c = context.colors;

    return Obx(() {
      final initial = convert.result.value;
      if (initial == null) return const SizedBox.shrink();
      // Read the live copy so it updates in place once it's in the folder.
      final file = files.find(initial.fileId) ?? initial;
      final progress = files.downloadProgress[file.fileId];
      final busy = progress != null;
      final took = convert.conversionTook.value;

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
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                        color: c.successSoft, shape: BoxShape.circle),
                    child: Icon(Icons.check_rounded, size: 40, color: c.success),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "done_title".trParams(
                      {"format": file.fileOutputFormat.toUpperCase()}),
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (took > Duration.zero) ...[
                  const SizedBox(height: 6),
                  Text(
                    "converted_in".trParams({"s": "${took.inSeconds.clamp(1, 9999)}"}),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                AppCard(
                  radius: 20,
                  child: Row(
                    children: [
                      FormatBadge(file.fileOutputFormat, size: 52),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleSmall),
                            const SizedBox(height: 3),
                            Text(
                              [
                                if (file.fileSize.isNotEmpty) file.fileSize,
                                if (file.isInFolder) "saved_in_folder".tr,
                              ].join(" · "),
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (busy) ...[
                  const SizedBox(height: 12),
                  ProgressBar(value: progress > 0 ? progress : null),
                ],
                const SizedBox(height: 16),
                if (!file.isInFolder && !busy) ...[
                  // Only when it couldn't be saved yet, e.g. no folder picked.
                  FilledButton.icon(
                    key: const Key("save_to_folder_button"),
                    onPressed: () => files.saveToFolder(file),
                    icon: const Icon(Icons.download_rounded),
                    label: Text("save_to_folder".tr),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  key: const Key("open_file_button"),
                  onPressed: busy ? null : () => files.open(file),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text("open".tr),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key("share_file_button"),
                  onPressed: busy ? null : () => files.share(file),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text("share".tr),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextButton.icon(
              key: const Key("convert_another_button"),
              onPressed: convert.reset,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text("convert_another".tr),
            ),
          ),
        ],
      );
    });
  }
}
