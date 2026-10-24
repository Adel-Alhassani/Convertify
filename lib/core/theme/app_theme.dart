import 'package:convertify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds the Material 3 theme from the design tokens.
///
/// Arabic uses Zain, which renders smaller than Inter at the same size, so its
/// type scale is bumped up.
class AppTheme {
  static ThemeData light({required bool arabic}) =>
      _build(AppColors.light, Brightness.light, arabic);

  static ThemeData dark({required bool arabic}) =>
      _build(AppColors.dark, Brightness.dark, arabic);

  static ThemeData _build(AppColors c, Brightness brightness, bool arabic) {
    final family = arabic ? "Zain" : "Inter";
    final s = arabic ? 1.18 : 1.0; // size factor

    TextStyle t(double size, FontWeight w, Color color,
            {double? height, double spacing = 0}) =>
        TextStyle(
          fontFamily: family,
          fontSize: size * s,
          fontWeight: w,
          color: color,
          height: height,
          letterSpacing: arabic ? 0 : spacing,
        );

    final textTheme = TextTheme(
      headlineMedium: t(28, FontWeight.w800, c.ink, height: 1.2, spacing: -0.6),
      headlineSmall: t(24, FontWeight.w800, c.ink, height: 1.25, spacing: -0.4),
      titleLarge: t(20, FontWeight.w800, c.ink, height: 1.3),
      titleMedium: t(17, FontWeight.w700, c.ink, height: 1.3),
      titleSmall: t(15, FontWeight.w600, c.ink, height: 1.3),
      bodyLarge: t(16, FontWeight.w400, c.ink, height: 1.45),
      bodyMedium: t(15, FontWeight.w400, c.muted, height: 1.45),
      bodySmall: t(13, FontWeight.w400, c.muted, height: 1.4),
      labelLarge: t(16, FontWeight.w700, c.ink),
      labelMedium: t(13, FontWeight.w600, c.ink),
      labelSmall: t(12, FontWeight.w700, c.muted, spacing: 0.6),
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.primaryInk,
      onSecondary: c.onPrimary,
      error: c.danger,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      outline: c.border,
      outlineVariant: c.border,
      surfaceContainerHighest: c.surfaceMuted,
    );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: family,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.ground,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: c.ground)
            : SystemUiOverlayStyle.light.copyWith(statusBarColor: c.ground),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceMuted,
          disabledForegroundColor: c.muted,
          minimumSize: const Size.fromHeight(56),
          shape: buttonShape,
          textStyle: t(17, FontWeight.w700, c.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          backgroundColor: c.surface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: c.border, width: 1.5),
          shape: buttonShape,
          textStyle: t(15, FontWeight.w700, c.ink),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primaryInk,
          minimumSize: const Size(44, 44),
          textStyle: t(15, FontWeight.w700, c.primaryInk),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.ink,
        side: BorderSide(color: c.border),
        shape: const StadiumBorder(),
        labelStyle: t(13, FontWeight.w600, c.ink),
        secondaryLabelStyle: t(13, FontWeight.w600, c.surface),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceMuted,
        hintStyle: t(15, FontWeight.w500, c.muted),
        prefixIconColor: c.muted,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primarySoft,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return t(12, selected ? FontWeight.w700 : FontWeight.w600,
              selected ? c.primaryInk : c.muted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? c.primaryInk : c.muted, size: 24);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      // Dialogs are styled in AppDialogs: DialogTheme vs DialogThemeData
      // differs across Flutter versions.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: t(14, FontWeight.w600, c.surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.primarySoft,
        circularTrackColor: c.primarySoft,
      ),
    );
  }
}
