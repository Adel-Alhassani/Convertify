import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/constant/app_config.dart';
import 'package:convertify/core/constant/format_info.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:convertify/view/widget/common/step_indicator.dart';
import 'package:convertify/view/widget/convert/format_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 1: nothing picked yet.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.onOpenFiles});

  final VoidCallback onOpenFiles;

  /// Picks a file, then shows the format sheet unless [preferred] could be
  /// preselected. Also used by the home-screen widget.
  static Future<void> pick({String? only, String? preferred}) async {
    final convert = Get.find<ConvertController>();
    final openSheet =
        await convert.pickFile(onlyExtension: only, preferredOutput: preferred);
    if (openSheet) await FormatPickerSheet.show();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const AppHeader(),
        const SizedBox(height: 20),
        Text("home_title".tr, style: text.headlineMedium),
        const SizedBox(height: 6),
        Text("home_subtitle"
            .trParams({"limit": "${AppConfig.fileSizeLimitInMB}"})),
        const SizedBox(height: 22),
        const StepIndicator(current: 0),
        const SizedBox(height: 22),
        _PickFileCard(onPick: () => pick()),
        const SizedBox(height: 24),
        SectionLabel("popular_conversions".tr),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (from, to) in FormatInfo.popularConversions)
              ActionChip(
                label: Text(
                  // Arrow follows reading direction.
                  Directionality.of(context) == TextDirection.rtl
                      ? "${from.toUpperCase()} ← ${to.toUpperCase()}"
                      : "${from.toUpperCase()} → ${to.toUpperCase()}",
                  style: const TextStyle(fontFamily: "Inter"),
                ),
                onPressed: () => pick(only: from, preferred: to),
              ),
          ],
        ),
        _RecentFile(onSeeAll: onOpenFiles),
      ],
    );
  }
}

class _PickFileCard extends StatelessWidget {
  const _PickFileCard({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(color: c.primaryBorder, radius: 22),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration:
                      BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
                  child: Icon(Icons.upload_rounded, size: 32, color: c.primary),
                ),
                const SizedBox(height: 14),
                Text("pick_title".tr,
                    style: text.titleMedium, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text("pick_subtitle".tr, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key("browse_files_button"),
                  onPressed: onPick,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text("browse_files".tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentFile extends StatelessWidget {
  const _RecentFile({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final files = Get.find<FilesController>();
    return Obx(() {
      final recent = files.mostRecent;
      if (recent == null) return const SizedBox.shrink();
      final busy = files.downloadProgress.containsKey(recent.fileId);
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(
              "recent".tr,
              trailing: TextButton(onPressed: onSeeAll, child: Text("see_all".tr)),
            ),
            const SizedBox(height: 6),
            AppCard(
              padding: const EdgeInsets.all(12),
              radius: 16,
              child: Row(
                children: [
                  FormatBadge(recent.fileOutputFormat),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recent.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (recent.fileSize.isNotEmpty) recent.fileSize,
                            FormatUtils.formatTimeAgo(recent.convertedAt),
                          ].join(" · "),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (busy)
                    TintedIconButton(
                      icon: Icons.hourglass_top_rounded,
                      tooltip: "save_to_folder".tr,
                      onPressed: null,
                    )
                  else if (recent.isInFolder)
                    TintedIconButton(
                      icon: Icons.open_in_new_rounded,
                      tooltip: "open".tr,
                      onPressed: () => files.open(recent),
                    )
                  else if (!files.isUnavailable(recent))
                    TintedIconButton(
                      icon: Icons.download_rounded,
                      tooltip: "save_to_folder".tr,
                      onPressed: () => files.saveToFolder(recent),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dash = 8.0, gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
            metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
