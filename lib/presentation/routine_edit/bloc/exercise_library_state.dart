import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';

class ExerciseLibraryState extends MviState {
  const ExerciseLibraryState({
    this.isLoading = true,
    this.isSaving = false,
    this.failure,
    this.exercises = const [],
    this.bodyPart,
    this.query = '',
  });

  final bool isLoading;
  final bool isSaving;
  final Failure? failure;

  /// The whole library, ordered by body part.
  final List<Exercise> exercises;

  /// Null means "every body part".
  final BodyPart? bodyPart;

  final String query;

  /// Filter and search run in memory: the library is small and this keeps the
  /// list from flickering on every keystroke.
  List<Exercise> get visible {
    final needle = query.trim().toLowerCase();
    return exercises.where((exercise) {
      if (bodyPart != null && exercise.bodyPart != bodyPart) return false;
      if (needle.isEmpty) return true;
      final haystack = [
        exercise.name,
        exercise.subTarget ?? '',
        exercise.equipment ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(needle);
    }).toList();
  }

  int get customCount => exercises.where((e) => e.isCustom).length;

  ExerciseLibraryState copyWith({
    bool? isLoading,
    bool? isSaving,
    Failure? failure,
    List<Exercise>? exercises,
    BodyPart? bodyPart,
    String? query,
    bool clearFailure = false,
    bool clearBodyPart = false,
  }) {
    return ExerciseLibraryState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
      exercises: exercises ?? this.exercises,
      bodyPart: clearBodyPart ? null : (bodyPart ?? this.bodyPart),
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    failure,
    exercises,
    bodyPart,
    query,
  ];
}
