import 'package:convertify/controller/convert_controller.dart';
import 'package:convertify/core/constant/format_info.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:convertify/view/widget/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Step 2: bottom sheet listing every output format, with search, category
/// filters and suggestions for the picked type.
class FormatPickerSheet extends StatefulWidget {
  const FormatPickerSheet({super.key});

  /// Uses the app's navigator context by default: the caller's view may have
  /// been replaced (home -> ready) by the time formats finish loading.
  static Future<void> show([BuildContext? context]) {
    return showModalBottomSheet<void>(
      context: context ?? Get.context!,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: FormatPickerSheet(),
      ),
    );
  }

  @override
  State<FormatPickerSheet> createState() => _FormatPickerSheetState();
}

class _FormatPickerSheetState extends State<FormatPickerSheet> {
  final convert = Get.find<ConvertController>();
  String _query = "";
  String? _group; // null = all

  void _choose(String format) {
    convert.selectFormat(format);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final input = convert.selectedFile.value?.extension ?? "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final groups = convert.validOutputFormats;
        final total = groups.values.fold<int>(0, (n, l) => n + l.length);
        final selected = convert.outputFormat.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("convert_to".tr, style: text.titleLarge),
                      if (total > 0)
                        Text(
                          "formats_available".trParams(
                              {"n": "$total", "format": input.toUpperCase()}),
                          style: text.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "close".tr,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                      backgroundColor: c.surfaceMuted, foregroundColor: c.ink),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (convert.isFormatsLoading.value)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (convert.formatsError.value != null)
              Expanded(child: _FormatsError(onRetry: convert.loadFormats))
            else ...[
              TextField(
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: "search_formats".tr,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              if (_query.isEmpty && groups.length > 1)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _GroupChip(
                        label: "group_all".tr,
                        selected: _group == null,
                        onTap: () => setState(() => _group = null),
                      ),
                      for (final g in groups.keys)
                        _GroupChip(
                          label: FormatInfo.groupLabelKey(g).tr,
                          selected: _group == g,
                          onTap: () => setState(() => _group = g),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 14, bottom: 24),
                  children: [
                    if (_query.isEmpty && _group == null)
                      ..._suggested(input, groups, selected),
                    ..._sections(groups, selected),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  List<Widget> _suggested(
      String input, Map<String, List<String>> groups, String selected) {
    final all = groups.values.expand((e) => e);
    final suggestions = FormatInfo.suggestionsFor(input, all);
    if (suggestions.isEmpty) return [];
    return [
      SectionLabel("suggested".tr),
      const SizedBox(height: 10),
      Row(
        children: [
          for (var i = 0; i < suggestions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _SuggestedTile(
                format: suggestions[i],
                highlighted: selected.isEmpty ? i == 0 : selected == suggestions[i],
                onTap: () => _choose(suggestions[i]),
              ),
            ),
          ],
          // Keep tiles the same width when there are fewer than three.
          for (var i = suggestions.length; i < 3; i++) ...[
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ],
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _sections(Map<String, List<String>> groups, String selected) {
    final widgets = <Widget>[];
    groups.forEach((group, formats) {
      if (_group != null && _group != group) return;
      final shown = _query.isEmpty
          ? formats
          : formats.where((f) => f.toLowerCase().contains(_query)).toList();
      if (shown.isEmpty) return;
      widgets
        ..add(SectionLabel(FormatInfo.groupLabelKey(group).tr))
        ..add(const SizedBox(height: 10))
        ..add(GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: [
            for (final f in shown)
              _FormatButton(
                format: f,
                selected: f == selected,
                onTap: () => _choose(f),
              ),
          ],
        ))
        ..add(const SizedBox(height: 18));
    });
    if (widgets.isEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text("no_formats_match".trParams({"q": _query}),
            textAlign: TextAlign.center),
      ));
    }
    return widgets;
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: selected ? c.surface : c.ink),
      ),
    );
  }
}

class _SuggestedTile extends StatelessWidget {
  const _SuggestedTile(
      {required this.format, required this.highlighted, required this.onTap});

  final String format;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final descKey = FormatInfo.descriptionKey(format);
    final fg = highlighted ? c.onPrimary : c.primaryInk;
    return Material(
      color: highlighted ? c.primary : c.primarySoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: highlighted
            ? BorderSide.none
            : BorderSide(color: c.primaryBorder, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(format.toUpperCase(),
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: fg)),
              if (descKey != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    descKey.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 11,
                        color: highlighted
                            ? c.onPrimary.withValues(alpha: 0.85)
                            : c.muted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton(
      {required this.format, required this.selected, required this.onTap});

  final String format;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.primary : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? c.primary : c.border),
        ),
        child: InkWell(
          key: Key("format_$format"),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              format.toUpperCase(),
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? c.onPrimary : c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatsError extends StatelessWidget {
  const _FormatsError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final error = Get.find<ConvertController>().formatsError.value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off_rounded, size: 40, color: c.muted),
        const SizedBox(height: 12),
        Text(error?.title ?? "error".tr,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(error?.message ?? "", textAlign: TextAlign.center),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text("try_again".tr),
          style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
        ),
      ],
    );
  }
}
