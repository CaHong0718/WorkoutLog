import 'package:flutter/material.dart';

import 'app_palette.dart';

/// The type scale from `design/DESIGN.md`.
///
/// Weights stop at 600 and there is no large title — the guide's two firmest
/// typographic rules. The getter names predate the guide; the comment on each
/// says which of its tokens it carries.
///
/// Every numeric style uses tabular figures so weights and timers do not jitter
/// as digits change.
class AppTypography {
  const AppTypography._(this._p);

  factory AppTypography.of(BuildContext context) =>
      AppTypography._(context.palette);

  final AppPalette _p;

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// `label` — section label above a card. No uppercase, no letter-spacing:
  /// both read as shouting and the guide rules them out.
  TextStyle get eyebrow => TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: _p.ink2,
  );

  /// `micro` — badges, statistic keys, weekday initials.
  TextStyle get label => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: _p.ink2,
  );

  /// `heading` — screen title. Sized like a card title on purpose.
  TextStyle get title => TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: _p.ink,
  );

  /// `heading` — card title.
  TextStyle get sectionTitle => title;

  /// `subhead` — list-row title, input value.
  TextStyle get cardTitle => TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: _p.ink,
  );

  /// `body`.
  TextStyle get body => TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: _p.ink2,
  );

  /// `caption` — subtitles, timestamps.
  TextStyle get caption => TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: _p.ink3,
  );

  /// `title` — statistic values. The largest text in the app apart from the
  /// rest countdown.
  TextStyle get metric => TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    fontFeatures: tabular,
    color: _p.ink,
  );

  /// `subhead` — inline number (weight × reps).
  TextStyle get numeric => TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    fontFeatures: tabular,
    color: _p.ink,
  );

  /// `timer` — rest countdown.
  TextStyle get timer => TextStyle(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    fontFeatures: tabular,
    color: _p.ink,
  );

  /// `button` — button label.
  TextStyle get button => const TextStyle(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );

  /// `tab` — bottom-navigation label.
  TextStyle get tab => const TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
  );
}

extension AppTypographyX on BuildContext {
  AppTypography get type => AppTypography.of(this);
}
