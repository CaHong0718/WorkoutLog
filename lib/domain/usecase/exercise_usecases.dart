import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/enums.dart';
import '../entity/exercise.dart';
import '../repository/exercise_repository.dart';

@injectable
class GetAllExercises {
  const GetAllExercises(this._repository);

  final ExerciseRepository _repository;

  Future<Result<List<Exercise>>> call() => _repository.getAll();
}

@injectable
class WatchExercises {
  const WatchExercises(this._repository);

  final ExerciseRepository _repository;

  Stream<List<Exercise>> call() => _repository.watchAll();
}

@injectable
class GetExercisesByBodyPart {
  const GetExercisesByBodyPart(this._repository);

  final ExerciseRepository _repository;

  Future<Result<List<Exercise>>> call(BodyPart bodyPart) =>
      _repository.getByBodyPart(bodyPart);
}

@injectable
class SearchExercises {
  const SearchExercises(this._repository);

  final ExerciseRepository _repository;

  Future<Result<List<Exercise>>> call(String query) =>
      _repository.search(query);
}

@injectable
class GetExercisesByIds {
  const GetExercisesByIds(this._repository);

  final ExerciseRepository _repository;

  Future<Result<List<Exercise>>> call(List<int> ids) =>
      _repository.getByIds(ids);
}

@injectable
class UpsertExercise {
  const UpsertExercise(this._repository);

  final ExerciseRepository _repository;

  Future<Result<int>> call(Exercise exercise) => _repository.upsert(exercise);
}

@injectable
class DeleteExercise {
  const DeleteExercise(this._repository);

  final ExerciseRepository _repository;

  Future<Result<void>> call(int id) => _repository.delete(id);
}
