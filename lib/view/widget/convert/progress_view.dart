import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Uploading and converting. Stays on the convert tab with three stages
/// instead of jumping to the Files tab mid-flow.
class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final convert = Get.find<ConvertController>();
    final text = Theme.of(context).textTheme;
    final c = context.colors;

    return Obx(() {
      final uploading = convert.stage.value == ConvertStage.uploading;
      final input = convert.activeInputFormat.value;
      final output = convert.outputFormat.value;
      final sent = FormatUtils.formatFileSizeWithUnits(convert.uploadedBytes.value);

      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                const AppHeader(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FormatBadge(input, size: 64),
                    const SizedBox(width: 14),
                    _MovingDots(color: c.primary),
                    const SizedBox(width: 14),
                    FormatBadge(output, size: 64),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  uploading ? "uploading_title".tr : "converting_title".tr,
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "${FormatUtils.formatFileName(convert.activeFileName.value, 34)}"
                  " ${Directionality.of(context) == TextDirection.rtl ? "←" : "→"} "
                  "${output.toUpperCase()}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppCard(
                  radius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    children: [
                      _StageRow(
                        state: uploading ? _Stage.active : _Stage.done,
                        title: uploading ? "stage_uploading".tr : "stage_uploaded".tr,
                        subtitle: uploading
                            ? "stage_upload_progress".trParams({
                                "sent": sent,
                                "total": convert.activeFileSize.value,
                              })
                            : convert.activeFileSize.value,
                        progress: uploading ? convert.uploadProgress.value : null,
                      ),
                      Divider(color: c.border),
                      _StageRow(
                        state: uploading ? _Stage.pending : _Stage.active,
                        title: "stage_converting"
                            .trParams({"format": output.toUpperCase()}),
                        subtitle: "stage_converting_hint".tr,
                        indeterminate: !uploading,
                      ),
                      Divider(color: c.border),
                      _StageRow(
                        state: _Stage.pending,
                        title: "stage_ready".tr,
                        subtitle: "stage_ready_hint".tr,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InfoNote(icon: Icons.folder_outlined, text: "can_leave".tr),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: OutlinedButton(
              key: const Key("cancel_conversion_button"),
              onPressed: convert.cancel,
              child: Text("cancel_conversion".tr),
            ),
          ),
        ],
      );
    });
  }
}

enum _Stage { done, active, pending }

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.state,
    required this.title,
    required this.subtitle,
    this.progress,
    this.indeterminate = false,
  });

  final _Stage state;
  final String title;
  final String subtitle;
  final double? progress;
  final bool indeterminate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    final Widget icon = switch (state) {
      _Stage.done => CircleAvatar(
          radius: 16,
          backgroundColor: c.successSoft,
          child: Icon(Icons.check_rounded, size: 18, color: c.success),
        ),
      _Stage.active => SizedBox(
          width: 32,
          height: 32,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              value: progress,
            ),
          ),
        ),
      _Stage.pending => Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.border, width: 1.5),
          ),
        ),
    };

    final showBar = state == _Stage.active && (progress != null || indeterminate);

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
                Text(
                  title,
                  style: text.titleSmall!.copyWith(
                    fontWeight: state == _Stage.pending
                        ? FontWeight.w600
                        : FontWeight.w700,
                    color: switch (state) {
                      _Stage.active => c.primaryInk,
                      _Stage.pending => c.muted,
                      _Stage.done => c.ink,
                    },
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: text.bodySmall),
                if (showBar) ...[
                  const SizedBox(height: 10),
                  ProgressBar(value: progress),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three dots that pulse left to right while work is happening.
class _MovingDots extends StatefulWidget {
  const _MovingDots({required this.color});

  final Color color;

  @override
  State<_MovingDots> createState() => _MovingDotsState();
}

class _MovingDotsState extends State<_MovingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Each dot peaks a third of a cycle after the previous one.
              final phase = (_controller.value - i / 3) % 1.0;
              final strength = phase < 0.5 ? 1 - phase * 2 : 0.0;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.25 + 0.75 * strength),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
