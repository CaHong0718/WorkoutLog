import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../../domain/entity/enums.dart';
import '../../domain/entity/exercise.dart';
import '../../domain/repository/exercise_repository.dart';
import '../database/daos/exercise_dao.dart';
import '../mapper/mappers.dart';
import 'data_errors.dart';

@LazySingleton(as: ExerciseRepository)
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._dao);

  final ExerciseDao _dao;

  @override
  Future<Result<List<Exercise>>> getAll() => runCatching(() async {
    final rows = await _dao.getAll();
    return rows.map((row) => row.toEntity()).toList();
  });

  @override
  Stream<List<Exercise>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((row) => row.toEntity()).toList());

  @override
  Future<Result<List<Exercise>>> getByBodyPart(BodyPart bodyPart) =>
      runCatching(() async {
        final rows = await _dao.byBodyPart(bodyPart.name);
        return rows.map((row) => row.toEntity()).toList();
      });

  @override
  Future<Result<List<Exercise>>> search(String query) => runCatching(() async {
    if (query.trim().isEmpty) {
      final rows = await _dao.getAll();
      return rows.map((row) => row.toEntity()).toList();
    }
    final rows = await _dao.search(query);
    return rows.map((row) => row.toEntity()).toList();
  });

  @override
  Future<Result<List<Exercise>>> getByIds(List<int> ids) =>
      runCatching(() async {
        final rows = await _dao.byIds(ids);
        return rows.map((row) => row.toEntity()).toList();
      });

  @override
  Future<Result<int>> upsert(Exercise exercise) => runCatching(() async {
    if (exercise.name.trim().isEmpty) {
      throw const ValidationException('종목 이름을 입력하세요.');
    }
    return _dao.upsert(exercise.id, exercise.toCompanion());
  }, onError: classifyFailure);

  @override
  Future<Result<void>> delete(int id) => runCatching(() async {
    if (await _dao.isReferencedByRoutine(id)) {
      throw const ValidationException('루틴에서 사용 중인 종목은 삭제할 수 없습니다.');
    }
    await _dao.deleteById(id);
  }, onError: classifyFailure);
}
