import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/shared/app_dialogs.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/common/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Asks before deleting. Files in the folder are deleted from the phone.
Future<bool> confirmDelete(DownloadableFileModel file) => AppDialogs.confirm(
      title: "delete_title".tr,
      message: (file.isInFolder ? "confirm_delete" : "confirm_remove")
          .trParams({"name": file.fileName}),
      confirmLabel: "delete".tr,
      destructive: true,
    );

/// One converted file. Tap for all actions, swipe to delete.
class FileTile extends StatelessWidget {
  const FileTile({super.key, required this.file});

  final DownloadableFileModel file;

  @override
  Widget build(BuildContext context) {
    final files = Get.find<FilesController>();
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Obx(() {
    final progress = files.downloadProgress[file.fileId];
    final busy = progress != null;
    final unavailable = files.isUnavailable(file);

    return Dismissible(
      key: ValueKey(file.fileId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(file),
      onDismissed: (_) => files.delete(file),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: c.dangerSoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_outline_rounded, color: c.danger),
      ),
      child: InkWell(
        onTap: () => _FileActionsSheet.show(context, file),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              FormatBadge(file.fileOutputFormat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall),
                    const SizedBox(height: 4),
                    if (busy)
                      ProgressBar(value: progress > 0 ? progress : null)
                    else
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            [
                              if (file.fileSize.isNotEmpty) file.fileSize,
                              FormatUtils.formatTimeAgo(file.convertedAt),
                            ].join(" · "),
                            style: text.bodySmall,
                          ),
                          if (!file.isInFolder)
                            _StatusPill(
                              label: unavailable
                                  ? "no_longer_available".tr
                                  : "not_saved_yet".tr,
                              urgent: unavailable,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (file.isInFolder)
                TintedIconButton(
                  icon: Icons.open_in_new_rounded,
                  tooltip: "open".tr,
                  primary: false,
                  onPressed: () => files.open(file),
                )
              else if (!unavailable)
                TintedIconButton(
                  icon: Icons.download_rounded,
                  tooltip: "save_to_folder".tr,
                  onPressed: busy ? null : () => files.saveToFolder(file),
                ),
            ],
          ),
        ),
      ),
    );
    });
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = urgent ? c.warning : c.ink.withValues(alpha: 0.8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: urgent ? c.warningSoft : c.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (urgent) ...[
            Icon(Icons.cloud_off_rounded, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontSize: 12,
                  color: fg,
                  fontWeight: urgent ? FontWeight.w700 : FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FileActionsSheet extends StatelessWidget {
  const _FileActionsSheet({required this.file});

  final DownloadableFileModel file;

  static Future<void> show(BuildContext context, DownloadableFileModel file) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => _FileActionsSheet(file: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    final files = Get.find<FilesController>();
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final unavailable = files.isUnavailable(file);

    void run(Future<void> Function() action) {
      Navigator.of(context).pop();
      action();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FormatBadge(file.fileOutputFormat, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall),
                    Text(
                      [
                        if (file.fileSize.isNotEmpty) file.fileSize,
                        FormatUtils.formatTimeAgo(file.convertedAt),
                      ].join(" · "),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!file.isInFolder && !unavailable)
            _ActionTile(
              icon: Icons.download_rounded,
              label: "save_to_folder".tr,
              onTap: () => run(() => files.saveToFolder(file)),
            ),
          if (!unavailable) ...[
            _ActionTile(
              icon: Icons.ios_share_rounded,
              label: "share".tr,
              onTap: () => run(() => files.share(file)),
            ),
            _ActionTile(
              icon: Icons.open_in_new_rounded,
              label: "open".tr,
              onTap: () => run(() => files.open(file)),
            ),
          ],
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            label: "delete".tr,
            color: c.danger,
            onTap: () => run(() async {
              if (await confirmDelete(file)) await files.delete(file);
            }),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: fg),
      title: Text(label,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: fg)),
      onTap: onTap,
    );
  }
}
