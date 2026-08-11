import 'package:flutter/material.dart';

import 'app_metrics.dart';
import 'app_palette.dart';

/// Builds [ThemeData] from the `design/DESIGN.md` tokens.
///
/// Component specs come straight from the guide's section 8: three button
/// kinds, borderless inputs that tint when focused, cards that use a 1px border
/// and never a shadow.
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onFill,
      secondary: p.accent,
      onSecondary: p.onFill,
      error: p.danger,
      onError: p.onFill,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface2,
      surfaceContainer: p.surface2,
      surfaceContainerHigh: p.surface3,
      surfaceContainerHighest: p.surface3,
      outline: p.line,
      outlineVariant: p.lineSoft,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.plane,
      canvasColor: p.plane,
      dividerColor: p.line,
      extensions: <ThemeExtension<dynamic>>[p],
      // Ripples overshoot; the guide asks for a flat state change instead.
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.plane,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppLayout.headerHeight,
        titleTextStyle: TextStyle(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: p.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      // Badge: micro type, no border, subtle fill.
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        side: BorderSide.none,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 5),
        labelStyle: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w500,
          color: p.ink2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.badge),
        ),
      ),
      // Primary.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onFill,
          disabledBackgroundColor: p.surface2,
          disabledForegroundColor: p.ink3,
          minimumSize: const Size(0, AppLayout.buttonHeight),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      // Secondary: transparent, one heavier border, weight 500.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, AppLayout.buttonHeight),
          side: BorderSide(color: p.lineStrong),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      // Ghost.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          minimumSize: const Size(0, AppLayout.minTouchTarget),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.ink2,
          minimumSize: const Size.square(AppLayout.minTouchTarget),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Focus swaps the fill to the accent tint. A WidgetStateColor is still
        // a Color, which is the only way to make this theme-wide.
        fillColor: WidgetStateColor.resolveWith(
          (states) =>
              states.contains(WidgetState.focused) ? p.accentWash : p.surface2,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        // Unfocused inputs carry no border at all — the fill is the affordance.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: p.danger),
        ),
        hintStyle: TextStyle(color: p.ink3, fontSize: 15),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentWash,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        height: AppLayout.tabBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            height: 14 / 11,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected) ? p.accent : p.ink3,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected) ? p.accent : p.ink3,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.lineStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.surface, fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.surface2,
        linearMinHeight: AppLayout.progressHeight,
        circularTrackColor: p.surface2,
      ),
      textTheme: _textTheme(p),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    return TextTheme(
      headlineMedium: TextStyle(
        color: p.ink,
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        color: p.ink,
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        color: p.ink,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      bodyLarge: TextStyle(color: p.ink, fontSize: 15, height: 22 / 15),
      bodyMedium: TextStyle(color: p.ink2, fontSize: 15, height: 22 / 15),
      bodySmall: TextStyle(color: p.ink3, fontSize: 13, height: 18 / 13),
      labelLarge: TextStyle(
        color: p.ink,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: p.ink2,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: p.ink2,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
