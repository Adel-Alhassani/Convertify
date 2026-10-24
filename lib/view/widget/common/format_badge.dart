import 'package:convertify/core/constant/format_info.dart';
import 'package:convertify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The coloured square with the format name, e.g. a red "PDF" tile.
class FormatBadge extends StatelessWidget {
  const FormatBadge(this.format, {super.key, this.size = 44});

  final String format;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = FormatInfo.badgeFor(format, context.colors);
    final label = format.toUpperCase();
    // Shrink long names like "DOCX" or "WEBP" so they fit.
    final fontSize = size * (label.length > 3 ? 0.24 : 0.27);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}
