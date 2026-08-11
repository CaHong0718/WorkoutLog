import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Text styles mirroring the reference document's type scale.
///
/// Every numeric style uses tabular figures so weights and timers do not
/// jitter as digits change.
class AppTypography {
  const AppTypography._(this._p);

  factory AppTypography.of(BuildContext context) =>
      AppTypography._(context.palette);

  final AppPalette _p;

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// Small uppercase section label above a title.
  TextStyle get eyebrow => TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: _p.accent,
  );

  /// Uppercase micro label (block codes, units).
  TextStyle get label => TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: _p.ink3,
  );

  /// Large screen title.
  TextStyle get title => TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: _p.ink,
  );

  TextStyle get sectionTitle => TextStyle(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: _p.ink,
  );

  TextStyle get cardTitle => TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: _p.ink,
  );

  TextStyle get body => TextStyle(
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: _p.ink2,
  );

  TextStyle get caption => TextStyle(
    fontSize: 12.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: _p.ink3,
  );

  /// Hero number (set counts, weekly volume).
  TextStyle get metric => TextStyle(
    fontSize: 34,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    fontFeatures: tabular,
    color: _p.ink,
  );

  /// Inline number (weight × reps).
  TextStyle get numeric => TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFeatures: tabular,
    color: _p.ink,
  );

  /// Rest timer readout.
  TextStyle get timer => TextStyle(
    fontSize: 48,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    fontFeatures: tabular,
    color: _p.ink,
  );
}

extension AppTypographyX on BuildContext {
  AppTypography get type => AppTypography.of(this);
}
