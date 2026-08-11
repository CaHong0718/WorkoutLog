import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';

sealed class ExerciseLibraryIntent extends MviIntent {
  const ExerciseLibraryIntent();
}

/// Subscribes to the library so an add or edit shows up without a refresh.
final class LoadLibrary extends ExerciseLibraryIntent {
  const LoadLibrary();
}

/// Null shows every body part.
final class FilterLibrary extends ExerciseLibraryIntent {
  const FilterLibrary(this.bodyPart);

  final BodyPart? bodyPart;

  @override
  List<Object?> get props => [bodyPart];
}

final class SearchLibrary extends ExerciseLibraryIntent {
  const SearchLibrary(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Inserts when the id is [Exercise.unsavedId], updates otherwise.
final class SaveExercise extends ExerciseLibraryIntent {
  const SaveExercise(this.exercise);

  final Exercise exercise;

  @override
  List<Object?> get props => [exercise];
}

/// Refused by the repository while a routine still references the exercise.
final class RemoveExercise extends ExerciseLibraryIntent {
  const RemoveExercise(this.exerciseId);

  final int exerciseId;

  @override
  List<Object?> get props => [exerciseId];
}
