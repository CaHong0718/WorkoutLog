import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Builds [ThemeData] from [AppPalette] tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.accentFill,
      onPrimary: p.onFill,
      secondary: p.accent,
      onSecondary: p.onFill,
      error: p.warn,
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
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.plane,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: p.line),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.lineSoft,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        side: BorderSide(color: p.line),
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: p.ink2,
        ),
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accentFill,
          foregroundColor: p.onFill,
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink2,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: p.line),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.accentFill, width: 1.6),
        ),
        hintStyle: TextStyle(color: p.ink3, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentWash,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? p.ink : p.ink3,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? p.accent : p.ink3,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.surface, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textTheme: _textTheme(p),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    return TextTheme(
      displayLarge: TextStyle(color: p.ink, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(
        color: p.ink,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        color: p.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: p.ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: p.ink, fontSize: 15, height: 1.5),
      bodyMedium: TextStyle(color: p.ink2, fontSize: 14, height: 1.55),
      bodySmall: TextStyle(color: p.ink3, fontSize: 12.5, height: 1.45),
      labelLarge: TextStyle(
        color: p.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: p.ink3,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
