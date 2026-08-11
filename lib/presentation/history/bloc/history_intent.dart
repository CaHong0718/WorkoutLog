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

/// Opens one session from the day panel.
///
/// [isInProgress] routes to the live session screen instead of the read-only
/// record — an unfinished workout tapped here should continue, not be reviewed.
final class OpenSessionRecord extends HistoryIntent {
  const OpenSessionRecord(this.sessionId, {this.isInProgress = false});

  final int sessionId;
  final bool isInProgress;

  @override
  List<Object?> get props => [sessionId, isInProgress];
}
