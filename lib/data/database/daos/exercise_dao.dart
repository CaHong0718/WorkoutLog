import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises, RoutineItems])
class ExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  Future<List<ExerciseRow>> getAll() =>
      (select(exercises)
            ..orderBy([
              (t) => OrderingTerm(expression: t.bodyPart),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .get();

  Stream<List<ExerciseRow>> watchAll() =>
      (select(exercises)
            ..orderBy([
              (t) => OrderingTerm(expression: t.bodyPart),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .watch();

  Future<List<ExerciseRow>> byBodyPart(String bodyPart) =>
      (select(exercises)
            ..where((t) => t.bodyPart.equals(bodyPart))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();

  Future<List<ExerciseRow>> search(String query) {
    final pattern = '%${query.trim()}%';
    return (select(exercises)
          ..where((t) => t.name.like(pattern) | t.subTarget.like(pattern))
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
  }

  Future<List<ExerciseRow>> byIds(List<int> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(exercises)..where((t) => t.id.isIn(ids))).get();
  }

  Future<ExerciseRow?> byName(String name) =>
      (select(exercises)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<int> upsert(int id, ExercisesCompanion companion) async {
    if (id == 0) return into(exercises).insert(companion);
    await (update(exercises)..where((t) => t.id.equals(id))).write(companion);
    return id;
  }

  Future<void> deleteById(int id) =>
      (delete(exercises)..where((t) => t.id.equals(id))).go();

  /// True when a routine still references this exercise — deletion must be
  /// refused so the routine does not lose a slot.
  Future<bool> isReferencedByRoutine(int exerciseId) async {
    final row = await (select(routineItems)
          ..where((t) => t.exerciseId.equals(exerciseId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
