import 'package:convertify/controller/ad_controller/banner_ad_controller.dart';
import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/controller/files_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/model/downloadable_file_model.dart';
import 'package:convertify/utils/format_utils.dart';
import 'package:convertify/view/widget/common/banner_ad_slot.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:convertify/view/widget/files/file_tile.dart';
import 'package:convertify/view/widget/files/in_progress_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key, required this.onOpenConvert});

  final VoidCallback onOpenConvert;

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final files = Get.find<FilesController>();
  final convert = Get.find<ConvertController>();
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchController.clear();
      files.query.value = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: _searching
                          ? TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (v) => files.query.value = v,
                              decoration: InputDecoration(
                                hintText: "search_in_files".tr,
                                prefixIcon: const Icon(Icons.search_rounded),
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          : Text("files_title".tr, style: text.headlineMedium),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: _searching ? "close".tr : "search_in_files".tr,
                      onPressed: _toggleSearch,
                      icon: Icon(_searching
                          ? Icons.close_rounded
                          : Icons.search_rounded),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        side: BorderSide(color: context.colors.border),
                        backgroundColor: context.colors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final visible = files.visibleFiles;
                final showProgress = convert.isBusy;

                return RefreshIndicator(
                  onRefresh: files.reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      if (!files.hasFolder.value) ...[
                        _FolderCard(onChoose: files.chooseFolder),
                        const SizedBox(height: 16),
                      ],
                      if (showProgress) ...[
                        InProgressCard(onTap: widget.onOpenConvert),
                        const SizedBox(height: 16),
                      ],
                      if (files.files.isEmpty && !showProgress)
                        _EmptyState(onConvert: widget.onOpenConvert)
                      else if (visible.isEmpty && files.files.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text("no_files_match".tr,
                              textAlign: TextAlign.center),
                        )
                      else
                        ..._grouped(visible),
                      if (files.files.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "files_footer".trParams({
                            "count": "${files.files.length}",
                            "size": FormatUtils.formatFileSizeWithUnits(
                                files.totalBytes),
                          }),
                          textAlign: TextAlign.center,
                          style: text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
            if (Get.isRegistered<BannerAdController>(tag: "files"))
              BannerAdSlot(
                  controller: Get.find<BannerAdController>(tag: "files")),
          ],
        ),
      ),
    );
  }

  List<Widget> _grouped(List<DownloadableFileModel> visible) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <String, List<DownloadableFileModel>>{};
    for (final f in visible) {
      final day =
          DateTime(f.convertedAt.year, f.convertedAt.month, f.convertedAt.day);
      final diff = today.difference(day).inDays;
      final label = diff == 0
          ? "today".tr
          : diff == 1
              ? "yesterday".tr
              : "${day.day}/${day.month}/${day.year}";
      groups.putIfAbsent(label, () => []).add(f);
    }
    final widgets = <Widget>[];
    groups.forEach((label, items) {
      widgets
        ..add(SectionLabel(label))
        ..add(const SizedBox(height: 8))
        ..add(AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                      indent: 14, endIndent: 14, color: context.colors.border),
                FileTile(file: items[i]),
              ],
            ],
          ),
        ))
        ..add(const SizedBox(height: 18));
    });
    return widgets;
  }
}

/// Shown until a folder is picked, and after a reinstall, when picking the
/// same folder brings the files back.
class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.onChoose});

  final Future<bool> Function() onChoose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.create_new_folder_outlined, color: c.primary),
              const SizedBox(width: 10),
              Expanded(
                  child: Text("folder_card_title".tr, style: text.titleSmall)),
            ],
          ),
          const SizedBox(height: 6),
          Text("folder_card_body".tr, style: text.bodySmall),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key("choose_folder_button"),
            onPressed: onChoose,
            child: Text("choose_folder".tr),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onConvert});

  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration:
                BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
            child: Icon(Icons.folder_open_rounded, size: 34, color: c.primary),
          ),
          const SizedBox(height: 16),
          Text("no_converted_files".tr,
              style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text("no_converted_files_hint".tr, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onConvert,
            style: FilledButton.styleFrom(minimumSize: const Size(180, 50)),
            child: Text("convert_a_file".tr),
          ),
        ],
      ),
    );
  }
}
