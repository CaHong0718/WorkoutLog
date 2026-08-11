extension DateTimeX on DateTime {
  /// Midnight of the same day — the canonical key for a workout session.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Monday 00:00 of the week this date belongs to.
  DateTime get startOfWeek {
    final d = dateOnly;
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  /// Sunday 00:00 of the week this date belongs to.
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// `월`, `화`, … for compact calendar headers.
  String get weekdayKo => switch (weekday) {
    DateTime.monday => '월',
    DateTime.tuesday => '화',
    DateTime.wednesday => '수',
    DateTime.thursday => '목',
    DateTime.friday => '금',
    DateTime.saturday => '토',
    _ => '일',
  };

  /// `2026. 8. 11. (화)`
  String get formatKo => '$year. $month. $day. ($weekdayKo)';

  /// `8/11`
  String get formatShort => '$month/$day';
}
