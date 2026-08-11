import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/routine_item.dart';

class DayEditState extends MviState {
  const DayEditState({
    this.isLoading = true,
    this.isSaving = false,
    this.failure,
    this.day,
    this.exercises = const [],
  });

  final bool isLoading;

  /// True while a write is in flight.
  final bool isSaving;

  final Failure? failure;

  final RoutineDay? day;

  /// Whole exercise library, so the pickers filter locally instead of
  /// hitting the database on every keystroke.
  final List<Exercise> exercises;

  bool get isReady => day != null;

  List<RoutineBlock> get blocks => day?.blocks ?? const [];

  Map<int, Exercise> get exercisesById => {
    for (final exercise in exercises) exercise.id: exercise,
  };

  /// Resolves an item's alternative ids against the library.
  List<Exercise> alternativesOf(RoutineItem item) {
    final byId = exercisesById;
    return item.alternativeExerciseIds
        .map((id) => byId[id])
        .whereType<Exercise>()
        .toList();
  }

  DayEditState copyWith({
    bool? isLoading,
    bool? isSaving,
    Failure? failure,
    RoutineDay? day,
    List<Exercise>? exercises,
    bool clearFailure = false,
  }) {
    return DayEditState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
      day: day ?? this.day,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, failure, day, exercises];
}
