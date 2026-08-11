extension DurationX on Duration {
  /// `05:30` — rest timers and short session clocks.
  String get mmss {
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// `1:05:30` when over an hour, `05:30` otherwise.
  String get clock {
    if (inHours == 0) return mmss;
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$inHours:$m:$s';
  }

  /// `38분`, `1시간 5분` — summaries.
  String get koreanShort {
    if (inHours == 0) return '$inMinutes분';
    final m = inMinutes.remainder(60);
    return m == 0 ? '$inHours시간' : '$inHours시간 $m분';
  }
}

extension IntDurationX on int {
  /// Seconds as a [Duration]; reads better than `Duration(seconds: x)` inline.
  Duration get seconds => Duration(seconds: this);
}
