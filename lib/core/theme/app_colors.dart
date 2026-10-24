import 'package:flutter/material.dart';

/// A background/foreground pair for a format badge.
class BadgeColors {
  final Color background;
  final Color foreground;
  const BadgeColors(this.background, this.foreground);

  static BadgeColors lerp(BadgeColors a, BadgeColors b, double t) =>
      BadgeColors(Color.lerp(a.background, b.background, t)!,
          Color.lerp(a.foreground, b.foreground, t)!);
}

/// Design tokens from the redesign, for light and dark mode.
/// Read with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color ground; // page background
  final Color surface; // cards, sheets, nav bar
  final Color surfaceMuted; // inputs, quiet buttons, info notes
  final Color border;
  final Color ink; // primary text
  final Color muted; // secondary text
  final Color primary; // buttons, active states
  final Color onPrimary;
  final Color primaryInk; // links and blue text (passes contrast on surface)
  final Color primarySoft; // tinted backgrounds
  final Color primaryBorder; // dashed pick area, outlined chips
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;

  final BadgeColors badgeBlue;
  final BadgeColors badgeRed;
  final BadgeColors badgeGreen;
  final BadgeColors badgeOrange;
  final BadgeColors badgePurple;
  final BadgeColors badgeGray;

  const AppColors({
    required this.ground,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.ink,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primaryInk,
    required this.primarySoft,
    required this.primaryBorder,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.badgeBlue,
    required this.badgeRed,
    required this.badgeGreen,
    required this.badgeOrange,
    required this.badgePurple,
    required this.badgeGray,
  });

  static const light = AppColors(
    ground: Color(0xFFF6F8FC),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEF2F8),
    border: Color(0xFFE3E8F2),
    ink: Color(0xFF0F172A),
    muted: Color(0xFF5B6474),
    primary: Color(0xFF2663FF),
    onPrimary: Color(0xFFFFFFFF),
    primaryInk: Color(0xFF1A4BD1),
    primarySoft: Color(0xFFEAF0FF),
    primaryBorder: Color(0xFFB9C9F5),
    success: Color(0xFF0E7A55),
    successSoft: Color(0xFFDDF3EA),
    warning: Color(0xFF9A4A00),
    warningSoft: Color(0xFFFFF1E0),
    danger: Color(0xFFB42318),
    dangerSoft: Color(0xFFFDECEA),
    badgeBlue: BadgeColors(Color(0xFFEAF0FF), Color(0xFF1A4BD1)),
    badgeRed: BadgeColors(Color(0xFFFDECEA), Color(0xFFB42318)),
    badgeGreen: BadgeColors(Color(0xFFE7F6EF), Color(0xFF0B6B4A)),
    badgeOrange: BadgeColors(Color(0xFFFFF1E0), Color(0xFF9A4A00)),
    badgePurple: BadgeColors(Color(0xFFF3EDFF), Color(0xFF5B2FC2)),
    badgeGray: BadgeColors(Color(0xFFEEF2F8), Color(0xFF334155)),
  );

  static const dark = AppColors(
    ground: Color(0xFF0B1220),
    surface: Color(0xFF131C2E),
    surfaceMuted: Color(0xFF1B2539),
    border: Color(0xFF26324A),
    ink: Color(0xFFE8EDF7),
    muted: Color(0xFF9AA6BA),
    primary: Color(0xFF4F82FF),
    onPrimary: Color(0xFFFFFFFF),
    primaryInk: Color(0xFF93B2FF),
    primarySoft: Color(0xFF1A2A52),
    primaryBorder: Color(0xFF34508F),
    success: Color(0xFF4CD3A0),
    successSoft: Color(0xFF12382B),
    warning: Color(0xFFF2B266),
    warningSoft: Color(0xFF3A2A14),
    danger: Color(0xFFFF8A7E),
    dangerSoft: Color(0xFF3D1C1A),
    badgeBlue: BadgeColors(Color(0xFF1A2A52), Color(0xFF93B2FF)),
    badgeRed: BadgeColors(Color(0xFF3D1C1A), Color(0xFFFF8A7E)),
    badgeGreen: BadgeColors(Color(0xFF12382B), Color(0xFF6FDCB0)),
    badgeOrange: BadgeColors(Color(0xFF3A2A14), Color(0xFFF2B266)),
    badgePurple: BadgeColors(Color(0xFF2A1F4A), Color(0xFFC2A8FF)),
    badgeGray: BadgeColors(Color(0xFF1B2539), Color(0xFFC3CCDB)),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      ground: c(ground, other.ground),
      surface: c(surface, other.surface),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      border: c(border, other.border),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      primaryInk: c(primaryInk, other.primaryInk),
      primarySoft: c(primarySoft, other.primarySoft),
      primaryBorder: c(primaryBorder, other.primaryBorder),
      success: c(success, other.success),
      successSoft: c(successSoft, other.successSoft),
      warning: c(warning, other.warning),
      warningSoft: c(warningSoft, other.warningSoft),
      danger: c(danger, other.danger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      badgeBlue: BadgeColors.lerp(badgeBlue, other.badgeBlue, t),
      badgeRed: BadgeColors.lerp(badgeRed, other.badgeRed, t),
      badgeGreen: BadgeColors.lerp(badgeGreen, other.badgeGreen, t),
      badgeOrange: BadgeColors.lerp(badgeOrange, other.badgeOrange, t),
      badgePurple: BadgeColors.lerp(badgePurple, other.badgePurple, t),
      badgeGray: BadgeColors.lerp(badgeGray, other.badgeGray, t),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
