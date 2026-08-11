/// Spacing, radius, layout and motion tokens from `design/DESIGN.md`.
///
/// Nothing here is invented — every value is one the guide names. A number that
/// is not in these scales does not belong in a widget; if a new one is really
/// needed, the guide gets amended first.
library;

abstract final class AppRadius {
  static const double badge = 10;
  static const double input = 12;
  static const double button = 14;
  static const double card = 18;
  static const double sheet = 24;

  /// Pills: avatars, toggles, date circles, progress bars.
  static const double full = 999;
}

abstract final class AppLayout {
  static const double screenPadding = 20;
  static const double cardPadding = 20;
  static const double rowPadding = 16;
  static const double rowHeight = 60;
  static const double sectionGap = 32;

  /// Section label to the card under it.
  static const double labelGap = 10;

  static const double minTouchTarget = 44;
  static const double headerHeight = 48;
  static const double tabBarHeight = 49;
  static const double buttonHeight = 52;
  static const double inputHeight = 44;
  static const double iconBox = 32;

  /// Progress bars are 7px: thin enough to stay quiet, thick enough that the
  /// rounded cap reads. 2px hairlines do not fit this tone.
  static const double progressHeight = 7;
}

abstract final class AppMotion {
  /// Colour and opacity changes.
  static const Duration fast = Duration(milliseconds: 150);

  /// Anything that moves.
  static const Duration normal = Duration(milliseconds: 200);
}
