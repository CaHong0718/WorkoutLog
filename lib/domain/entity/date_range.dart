import 'package:equatable/equatable.dart';

/// Inclusive date window. Domain-owned so the layer stays free of Flutter's
/// `DateTimeRange`.
class DateRange extends Equatable {
  const DateRange({required this.start, required this.end});

  factory DateRange.week(DateTime anyDayInWeek) {
    final d = DateTime(anyDayInWeek.year, anyDayInWeek.month, anyDayInWeek.day);
    final start = d.subtract(Duration(days: d.weekday - DateTime.monday));
    return DateRange(start: start, end: start.add(const Duration(days: 6)));
  }

  factory DateRange.month(DateTime anyDayInMonth) => DateRange(
    start: DateTime(anyDayInMonth.year, anyDayInMonth.month),
    end: DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 0),
  );

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  @override
  List<Object?> get props => [start, end];
}
