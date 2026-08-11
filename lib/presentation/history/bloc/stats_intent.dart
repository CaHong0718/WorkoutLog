import '../../../core/mvi/mvi_intent.dart';

sealed class StatsIntent extends MviIntent {
  const StatsIntent();
}

/// Initial load: weekly volume, routine target and the trend candidates.
final class LoadStats extends StatsIntent {
  const LoadStats();
}

/// Moves the volume week by [delta] weeks (−1 back, +1 forward).
final class ChangeWeek extends StatsIntent {
  const ChangeWeek(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

/// Redraws the trend chart for another exercise.
final class SelectTrendExercise extends StatsIntent {
  const SelectTrendExercise(this.exerciseId);

  final int exerciseId;

  @override
  List<Object?> get props => [exerciseId];
}
