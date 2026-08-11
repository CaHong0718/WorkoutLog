import 'package:equatable/equatable.dart';

/// One session's best effort on a single exercise, for the progress chart.
class ExerciseProgressPoint extends Equatable {
  const ExerciseProgressPoint({
    required this.date,
    required this.topWeight,
    required this.reps,
    required this.totalVolume,
  });

  final DateTime date;

  /// Heaviest weight used that day.
  final double topWeight;

  /// Reps achieved at [topWeight].
  final int reps;

  /// Tonnage across every set of the exercise that day.
  final double totalVolume;

  /// Epley estimate — smooths out rep-range changes between sessions.
  double get estimated1RM => topWeight * (1 + reps / 30);

  @override
  List<Object?> get props => [date, topWeight, reps, totalVolume];
}
