import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'routine_dao.g.dart';

@DriftAccessor(
  tables: [
    Routines,
    RoutineDays,
    RoutineBlocks,
    RoutineItems,
    Exercises,
    WorkoutSessions,
  ],
)
class RoutineDao extends DatabaseAccessor<AppDatabase> with _$RoutineDaoMixin {
  RoutineDao(super.db);

  // ── read ────────────────────────────────────────────────────────────────

  Future<RoutineRow?> findActiveRoutine() =>
      (select(routines)
            ..where((t) => t.isActive.equals(true))
            ..limit(1))
          .getSingleOrNull();

  Future<List<RoutineRow>> allRoutines() =>
      (select(routines)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  Future<RoutineRow?> findRoutine(int routineId) =>
      (select(routines)
            ..where((t) => t.id.equals(routineId)))
          .getSingleOrNull();

  Future<List<RoutineDayRow>> daysOf(int routineId) =>
      (select(routineDays)
            ..where((t) => t.routineId.equals(routineId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<RoutineDayRow?> findDay(int dayId) =>
      (select(routineDays)..where((t) => t.id.equals(dayId))).getSingleOrNull();

  Future<List<RoutineBlockRow>> blocksOf(List<int> dayIds) {
    if (dayIds.isEmpty) return Future.value(const []);
    return (select(routineBlocks)
          ..where((t) => t.dayId.isIn(dayIds))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<List<RoutineItemRow>> itemsOf(List<int> blockIds) {
    if (blockIds.isEmpty) return Future.value(const []);
    return (select(routineItems)
          ..where((t) => t.blockId.isIn(blockIds))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<List<ExerciseRow>> exercisesByIds(Iterable<int> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(exercises)..where((t) => t.id.isIn(ids.toList()))).get();
  }

  /// Batch name lookup used by import to reconcile against the library.
  /// Duplicate names would break `getSingleOrNull`, so this returns rows.
  Future<List<ExerciseRow>> exercisesByNames(Iterable<String> names) {
    if (names.isEmpty) return Future.value(const []);
    return (select(exercises)..where((t) => t.name.isIn(names.toList()))).get();
  }

  /// A routine with a live session cannot be deleted: the session rebuilds its
  /// plan from the day graph, so removing it mid-workout breaks the screen.
  Future<bool> hasInProgressSession(int routineId) async {
    final row =
        await (select(workoutSessions)
              ..where(
                (t) =>
                    t.routineId.equals(routineId) &
                    t.status.equals('inProgress'),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Latest completed session of [routineId] — the anchor for the rotation.
  Future<WorkoutSessionRow?> lastCompletedSession(int routineId) =>
      (select(workoutSessions)
            ..where(
              (t) =>
                  t.routineId.equals(routineId) & t.status.equals('completed'),
            )
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  // ── write ───────────────────────────────────────────────────────────────

  Future<int> insertRoutine(RoutinesCompanion companion) =>
      into(routines).insert(companion);

  Future<void> updateRoutine(int id, RoutinesCompanion companion) =>
      (update(routines)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteRoutine(int id) =>
      (delete(routines)..where((t) => t.id.equals(id))).go();

  /// Clears every flag before setting one, in a single transaction — two
  /// active routines would make `findActiveRoutine` pick arbitrarily.
  Future<void> setActiveRoutine(int id) => transaction(() async {
    await update(routines).write(const RoutinesCompanion(isActive: Value(false)));
    await (update(routines)..where((t) => t.id.equals(id))).write(
      RoutinesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  Future<int> insertExercise(ExercisesCompanion companion) =>
      into(exercises).insert(companion);

  Future<int> upsertDay(int id, RoutineDaysCompanion companion) async {
    if (id == 0) return into(routineDays).insert(companion);
    await (update(routineDays)..where((t) => t.id.equals(id))).write(companion);
    return id;
  }

  Future<void> deleteDay(int id) =>
      (delete(routineDays)..where((t) => t.id.equals(id))).go();

  Future<int> upsertBlock(int id, RoutineBlocksCompanion companion) async {
    if (id == 0) return into(routineBlocks).insert(companion);
    await (update(routineBlocks)
          ..where((t) => t.id.equals(id)))
        .write(companion);
    return id;
  }

  Future<void> deleteBlock(int id) =>
      (delete(routineBlocks)..where((t) => t.id.equals(id))).go();

  Future<int> upsertItem(int id, RoutineItemsCompanion companion) async {
    if (id == 0) return into(routineItems).insert(companion);
    await (update(routineItems)..where((t) => t.id.equals(id))).write(companion);
    return id;
  }

  Future<void> deleteItem(int id) =>
      (delete(routineItems)..where((t) => t.id.equals(id))).go();

  /// Rewrites `sortOrder` to match the position of each id in [orderedIds].
  Future<void> reorderDays(List<int> orderedIds) => _reorder(
    orderedIds,
    (id, index) => (update(routineDays)..where((t) => t.id.equals(id)))
        .write(RoutineDaysCompanion(sortOrder: Value(index))),
  );

  Future<void> reorderBlocks(List<int> orderedIds) => _reorder(
    orderedIds,
    (id, index) => (update(routineBlocks)..where((t) => t.id.equals(id)))
        .write(RoutineBlocksCompanion(sortOrder: Value(index))),
  );

  Future<void> reorderItems(List<int> orderedIds) => _reorder(
    orderedIds,
    (id, index) => (update(routineItems)..where((t) => t.id.equals(id)))
        .write(RoutineItemsCompanion(sortOrder: Value(index))),
  );

  Future<void> _reorder(
    List<int> orderedIds,
    Future<void> Function(int id, int index) writeOrder,
  ) => transaction(() async {
    for (var i = 0; i < orderedIds.length; i++) {
      await writeOrder(orderedIds[i], i);
    }
  });

  /// Next free `sortOrder` inside a parent, used when appending.
  Future<int> nextBlockOrder(int dayId) async {
    final rows = await blocksOf([dayId]);
    return rows.isEmpty ? 0 : rows.last.sortOrder + 1;
  }

  Future<int> nextItemOrder(int blockId) async {
    final rows = await itemsOf([blockId]);
    return rows.isEmpty ? 0 : rows.last.sortOrder + 1;
  }
}
