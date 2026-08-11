import '../../core/result/result.dart';
import '../entity/enums.dart';
import '../entity/exercise.dart';

abstract interface class ExerciseRepository {
  Future<Result<List<Exercise>>> getAll();

  Stream<List<Exercise>> watchAll();

  Future<Result<List<Exercise>>> getByBodyPart(BodyPart bodyPart);

  Future<Result<List<Exercise>>> search(String query);

  Future<Result<List<Exercise>>> getByIds(List<int> ids);

  /// Inserts when [Exercise.id] is [Exercise.unsavedId], updates otherwise.
  Future<Result<int>> upsert(Exercise exercise);

  /// Fails with a [ValidationFailure] when the exercise is still referenced by
  /// a routine item.
  Future<Result<void>> delete(int id);
}
