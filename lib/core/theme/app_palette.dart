import 'package:flutter/material.dart';

/// Colour tokens from `design/DESIGN.md`.
///
/// The field names predate the guide; the values are the guide's. The mapping:
/// `plane`=bg, `surface`=surface, `surface2`/`surface3`=bgSubtle, `ink`=text,
/// `ink2`=textSecondary, `ink3`=textTertiary, `line`/`lineSoft`=border,
/// `lineStrong`=borderStrong, `accent`/`accentFill`=accent,
/// `accentWash`=accentSoft.
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
    required this.lineStrong,
    required this.accent,
    required this.accentFill,
    required this.accentWash,
    required this.onFill,
    required this.warn,
    required this.danger,
    required this.back,
    required this.chest,
    required this.shoulder,
    required this.legs,
    required this.arms,
    required this.abs,
  });

  /// Page background. In light it matches [surface] — cards are told apart by
  /// their border, not by a darker page behind them.
  final Color plane;
  final Color surface;

  /// Subtle fill inside a card: icon boxes, inputs, progress tracks.
  final Color surface2;

  /// Second subtle fill. Same value as [surface2] in this system — the guide
  /// has one subtle step, and stacking two of them was never doing any work.
  final Color surface3;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color ink2;

  /// Tertiary text, placeholders, chevrons.
  final Color ink3;

  final Color line;
  final Color lineSoft;

  /// Heavier border: secondary buttons, toggles in the off position.
  final Color lineStrong;

  /// The one accent. [accentFill] is the same colour — the guide allows a
  /// single accent, so text-accent and fill-accent no longer diverge.
  final Color accent;
  final Color accentFill;

  /// Opaque accent tint for active inputs and selected surfaces.
  final Color accentWash;

  /// Text drawn on top of [accentFill].
  final Color onFill;

  /// Caution: an overrun timer, a block that cannot be cut, an import notice.
  final Color warn;

  /// Errors and destructive actions.
  final Color danger;

  // Body-part identity colours. Not accents — they carry information, so they
  // stay distinct from each other and from [accent].
  final Color back;
  final Color chest;
  final Color shoulder;
  final Color legs;
  final Color arms;
  final Color abs;

  static const AppPalette light = AppPalette(
    plane: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF7F7F8),
    surface3: Color(0xFFF7F7F8),
    ink: Color(0xFF18181B),
    ink2: Color(0xFF71717A),
    ink3: Color(0xFFA1A1AA),
    line: Color(0xFFE9E9EC),
    lineSoft: Color(0xFFE9E9EC),
    lineStrong: Color(0xFFD4D4D8),
    accent: Color(0xFF2563EB),
    accentFill: Color(0xFF2563EB),
    accentWash: Color(0xFFEFF4FF),
    onFill: Color(0xFFFFFFFF),
    warn: Color(0xFFCA8A04),
    danger: Color(0xFFDC2626),
    back: Color(0xFF0891B2),
    chest: Color(0xFFE11D48),
    shoulder: Color(0xFFD97706),
    legs: Color(0xFF059669),
    arms: Color(0xFF7C3AED),
    abs: Color(0xFF71717A),
  );

  static const AppPalette dark = AppPalette(
    plane: Color(0xFF09090B),
    surface: Color(0xFF161619),
    // Must stay brighter than surface, or icon boxes and inputs sink into the
    // card they sit on. This has bitten before.
    surface2: Color(0xFF202024),
    surface3: Color(0xFF202024),
    ink: Color(0xFFFAFAFA),
    ink2: Color(0xFFA1A1AA),
    ink3: Color(0xFF71717A),
    line: Color(0xFF26262A),
    lineSoft: Color(0xFF26262A),
    lineStrong: Color(0xFF3F3F46),
    accent: Color(0xFF3B82F6),
    accentFill: Color(0xFF3B82F6),
    accentWash: Color(0xFF17233D),
    onFill: Color(0xFFFFFFFF),
    warn: Color(0xFFEAB308),
    danger: Color(0xFFEF4444),
    back: Color(0xFF06B6D4),
    chest: Color(0xFFF43F5E),
    shoulder: Color(0xFFF59E0B),
    legs: Color(0xFF10B981),
    arms: Color(0xFF8B5CF6),
    abs: Color(0xFFA1A1AA),
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
    Color? lineStrong,
    Color? accent,
    Color? accentFill,
    Color? accentWash,
    Color? onFill,
    Color? warn,
    Color? danger,
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
      lineStrong: lineStrong ?? this.lineStrong,
      accent: accent ?? this.accent,
      accentFill: accentFill ?? this.accentFill,
      accentWash: accentWash ?? this.accentWash,
      onFill: onFill ?? this.onFill,
      warn: warn ?? this.warn,
      danger: danger ?? this.danger,
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
      lineStrong: mix(lineStrong, other.lineStrong),
      accent: mix(accent, other.accent),
      accentFill: mix(accentFill, other.accentFill),
      accentWash: mix(accentWash, other.accentWash),
      onFill: mix(onFill, other.onFill),
      warn: mix(warn, other.warn),
      danger: mix(danger, other.danger),
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
