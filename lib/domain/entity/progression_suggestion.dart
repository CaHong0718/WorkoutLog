import 'package:equatable/equatable.dart';

/// Outcome of the double-progression rule for one exercise.
///
/// The reference program's rule: once the **top of the rep range is hit on
/// every set**, add 2.5–5% and drop back to the bottom of the range.
class ProgressionSuggestion extends Equatable {
  const ProgressionSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.shouldIncrease,
    this.currentWeight,
    this.suggestedWeight,
    this.reason = '',
  });

  factory ProgressionSuggestion.hold(
    int exerciseId,
    String exerciseName, {
    double? currentWeight,
    String reason = '',
  }) => ProgressionSuggestion(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    shouldIncrease: false,
    currentWeight: currentWeight,
    reason: reason,
  );

  final int exerciseId;
  final String exerciseName;
  final bool shouldIncrease;
  final double? currentWeight;
  final double? suggestedWeight;

  /// Short Korean explanation shown next to the suggestion.
  final String reason;

  @override
  List<Object?> get props => [
    exerciseId,
    exerciseName,
    shouldIncrease,
    currentWeight,
    suggestedWeight,
    reason,
  ];
}
