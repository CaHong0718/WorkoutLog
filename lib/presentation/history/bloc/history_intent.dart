import '../../../core/mvi/mvi_intent.dart';

sealed class HistoryIntent extends MviIntent {
  const HistoryIntent();
}

/// Initial load and pull-to-refresh: calendar month, totals and streak.
final class LoadHistory extends HistoryIntent {
  const LoadHistory();
}

/// Moves the calendar by [delta] months (−1 back, +1 forward).
final class ChangeMonth extends HistoryIntent {
  const ChangeMonth(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

/// Picks a calendar day and loads the sessions recorded on it.
final class SelectDate extends HistoryIntent {
  const SelectDate(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// Opens the detail screen of one recorded session.
final class OpenSessionRecord extends HistoryIntent {
  const OpenSessionRecord(this.sessionId);

  final int sessionId;

  @override
  List<Object?> get props => [sessionId];
}
