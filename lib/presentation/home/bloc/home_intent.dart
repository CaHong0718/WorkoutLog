import '../../../core/mvi/mvi_intent.dart';

sealed class HomeIntent extends MviIntent {
  const HomeIntent();
}

/// Initial load and pull-to-refresh.
final class LoadHome extends HomeIntent {
  const LoadHome();
}

/// Overrides the rotation and shows a different day.
final class SelectDay extends HomeIntent {
  const SelectDay(this.dayId);

  final int dayId;

  @override
  List<Object?> get props => [dayId];
}

/// Creates a session for the selected day and navigates to it.
final class StartWorkout extends HomeIntent {
  const StartWorkout();
}

/// Opens the session that was left unfinished.
final class ResumeWorkout extends HomeIntent {
  const ResumeWorkout();
}

/// Discards the unfinished session without opening it.
final class DiscardInProgress extends HomeIntent {
  const DiscardInProgress();
}
