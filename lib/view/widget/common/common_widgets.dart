import 'package:convertify/controller/config_controller.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Logo, app name and the language switch.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.trailing});

  /// Replaces the language switch (e.g. "Start over").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: c.primary, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.swap_horiz_rounded, color: c.onPrimary, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            "Convertify",
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: c.ink,
            ),
          ),
          const Spacer(),
          trailing ?? const LanguageSwitch(),
        ],
      ),
    );
  }
}

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ConfigController>();
    final c = context.colors;
    return Semantics(
      button: true,
      label: "switch_language".tr,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: config.toggleLanguage,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          side: BorderSide(color: c.border),
          shape: const StadiumBorder(),
        ),
        child: Text(config.isArabic ? "EN" : "عربي",
            style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

/// Small uppercase heading above a group ("POPULAR CONVERSIONS").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall);
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [label, trailing!],
    );
  }
}

/// Grey note with an icon, e.g. "Files are kept for 24 hours".
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.ink.withValues(alpha: 0.75)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: c.ink.withValues(alpha: 0.85), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// White rounded card with a hairline border.
class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.borderColor,
      this.radius = 18});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.border),
      ),
      child: child,
    );
  }
}

/// A square icon button with a tinted background (download, open, cancel).
class TintedIconButton extends StatelessWidget {
  const TintedIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.primary = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: primary ? c.primarySoft : c.surfaceMuted,
        foregroundColor: primary ? c.primaryInk : c.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Thin rounded progress bar. [value] null = indeterminate.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, this.value, this.color, this.trackColor});

  final double? value;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }
}
