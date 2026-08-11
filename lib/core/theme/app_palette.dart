import 'package:flutter/material.dart';

/// Design tokens carried over from `무분할-40분-루틴.html`.
///
/// Access with `context.palette` (see [AppPaletteX]).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.plane,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.lineSoft,
    required this.accent,
    required this.accentFill,
    required this.accentWash,
    required this.onFill,
    required this.warn,
    required this.back,
    required this.chest,
    required this.shoulder,
    required this.legs,
    required this.arms,
    required this.abs,
  });

  /// Page background, one step behind [surface].
  final Color plane;
  final Color surface;
  final Color surface2;
  final Color surface3;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color ink2;

  /// Tertiary text, labels.
  final Color ink3;

  final Color line;
  final Color lineSoft;

  final Color accent;
  final Color accentFill;
  final Color accentWash;

  /// Text drawn on top of [accentFill].
  final Color onFill;
  final Color warn;

  // Body-part identity colors.
  final Color back;
  final Color chest;
  final Color shoulder;
  final Color legs;
  final Color arms;
  final Color abs;

  static const AppPalette light = AppPalette(
    plane: Color(0xFFE7E9EE),
    surface: Color(0xFFFAFBFC),
    surface2: Color(0xFFF1F3F6),
    surface3: Color(0xFFE9ECF1),
    ink: Color(0xFF13161B),
    ink2: Color(0xFF4C5461),
    ink3: Color(0xFF7E8797),
    line: Color(0xFFD5D9E1),
    lineSoft: Color(0xFFE3E6EC),
    accent: Color(0xFF0F6B55),
    accentFill: Color(0xFF2FA98C),
    accentWash: Color(0x212FA98C),
    onFill: Color(0xFFFFFFFF),
    warn: Color(0xFFB4531B),
    back: Color(0xFF3B7DD8),
    chest: Color(0xFFD94F70),
    shoulder: Color(0xFFE0912F),
    legs: Color(0xFF2FA98C),
    arms: Color(0xFF8A6BD1),
    abs: Color(0xFF7E8797),
  );

  static const AppPalette dark = AppPalette(
    plane: Color(0xFF0C0E12),
    surface: Color(0xFF171A20),
    surface2: Color(0xFF1D2129),
    surface3: Color(0xFF232830),
    ink: Color(0xFFEDEFF3),
    ink2: Color(0xFFA3ABBA),
    ink3: Color(0xFF6C7585),
    line: Color(0xFF282D37),
    lineSoft: Color(0xFF20242C),
    accent: Color(0xFF3FCCA6),
    accentFill: Color(0xFF23A484),
    accentWash: Color(0x2923A484),
    onFill: Color(0xFF0C0E12),
    warn: Color(0xFFE0975F),
    back: Color(0xFF4C8AE0),
    chest: Color(0xFFDC5F7D),
    shoulder: Color(0xFFBF7E22),
    legs: Color(0xFF23A484),
    arms: Color(0xFF907AD8),
    abs: Color(0xFF6C7585),
  );

  @override
  AppPalette copyWith({
    Color? plane,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? lineSoft,
    Color? accent,
    Color? accentFill,
    Color? accentWash,
    Color? onFill,
    Color? warn,
    Color? back,
    Color? chest,
    Color? shoulder,
    Color? legs,
    Color? arms,
    Color? abs,
  }) {
    return AppPalette(
      plane: plane ?? this.plane,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      accent: accent ?? this.accent,
      accentFill: accentFill ?? this.accentFill,
      accentWash: accentWash ?? this.accentWash,
      onFill: onFill ?? this.onFill,
      warn: warn ?? this.warn,
      back: back ?? this.back,
      chest: chest ?? this.chest,
      shoulder: shoulder ?? this.shoulder,
      legs: legs ?? this.legs,
      arms: arms ?? this.arms,
      abs: abs ?? this.abs,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      plane: mix(plane, other.plane),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      surface3: mix(surface3, other.surface3),
      ink: mix(ink, other.ink),
      ink2: mix(ink2, other.ink2),
      ink3: mix(ink3, other.ink3),
      line: mix(line, other.line),
      lineSoft: mix(lineSoft, other.lineSoft),
      accent: mix(accent, other.accent),
      accentFill: mix(accentFill, other.accentFill),
      accentWash: mix(accentWash, other.accentWash),
      onFill: mix(onFill, other.onFill),
      warn: mix(warn, other.warn),
      back: mix(back, other.back),
      chest: mix(chest, other.chest),
      shoulder: mix(shoulder, other.shoulder),
      legs: mix(legs, other.legs),
      arms: mix(arms, other.arms),
      abs: mix(abs, other.abs),
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Design tokens for the current theme brightness.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
