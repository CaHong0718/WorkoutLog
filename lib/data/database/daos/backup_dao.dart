import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'backup_dao.g.dart';

/// Whole-database reads and writes for `docs/07-BACKUP.md`.
///
/// The routine graph is *not* rebuilt here — `RoutineRepository.importRoutine`
/// already knows how, and a backup restore calls it rather than growing a
/// second copy of that code. What is left is the library, the history, and the
/// ability to empty every table.
@DriftAccessor(
  tables: [
    Exercises,
    Routines,
    RoutineDays,
    RoutineBlocks,
    RoutineItems,
    WorkoutSessions,
    SetLogs,
  ],
)
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.db);

  // ── reading ───────────────────────────────────────────────────────────────

  Future<List<ExerciseRow>> allExercises() =>
      (select(exercises)..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();

  Future<List<RoutineRow>> allRoutines() =>
      (select(routines)..orderBy([(t) => OrderingTerm(expression: t.id)])).get();

  /// Everything except the workout in progress — that one is this phone's
  /// current state, not a record (`docs/07-BACKUP.md` §5).
  Future<List<WorkoutSessionRow>> finishedSessions() =>
      (select(workoutSessions)
            ..where((t) => t.status.equals('inProgress').not())
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .get();

  /// Logs for [sessionIds], already in display order.
  Future<List<SetLogRow>> logsOfSessions(List<int> sessionIds) {
    if (sessionIds.isEmpty) return Future.value(const []);
    return (select(setLogs)
          ..where((t) => t.sessionId.isIn(sessionIds))
          ..orderBy([
            (t) => OrderingTerm(expression: t.itemOrder),
            (t) => OrderingTerm(expression: t.setIndex),
          ]))
        .get();
  }

  /// Start instants already on file — the identity a merge restore dedupes on.
  Future<Set<DateTime>> sessionStartTimes() async {
    final query = selectOnly(workoutSessions)
      ..addColumns([workoutSessions.startedAt]);
    final rows = await query.get();
    return {
      for (final row in rows)
        if (row.read(workoutSessions.startedAt) case final DateTime at) at,
    };
  }

  Future<bool> hasSessionInProgress() async {
    final row =
        await (select(workoutSessions)
              ..where((t) => t.status.equals('inProgress'))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Days of one routine, so a restored session can be reattached by its
  /// `dayCode` snapshot.
  Future<List<RoutineDayRow>> daysOf(int routineId) =>
      (select(routineDays)..where((t) => t.routineId.equals(routineId))).get();

  Future<({int routines, int exercises, int sessions, int sets, DateTime? first, DateTime? last})>
  counts() async {
    final routineCount = await _count(routines);
    final exerciseCount = await _count(exercises);
    final sessionCount = await _count(workoutSessions);
    final setCount = await _count(setLogs);

    final min = workoutSessions.date.min();
    final max = workoutSessions.date.max();
    final range = await (selectOnly(workoutSessions)..addColumns([min, max]))
        .getSingleOrNull();

    return (
      routines: routineCount,
      exercises: exerciseCount,
      sessions: sessionCount,
      sets: setCount,
      first: range?.read(min),
      last: range?.read(max),
    );
  }

  Future<int> _count(TableInfo<Table, dynamic> table) async {
    final expression = countAll();
    final row = await (selectOnly(table)..addColumns([expression]))
        .getSingle();
    return row.read(expression) ?? 0;
  }

  // ── writing ───────────────────────────────────────────────────────────────

  Future<int> insertExercise(ExercisesCompanion companion) =>
      into(exercises).insert(companion);

  Future<int> insertSession(WorkoutSessionsCompanion companion) =>
      into(workoutSessions).insert(companion);

  /// One statement per batch rather than per set — a year of training is a few
  /// thousand rows.
  Future<void> insertSetLogs(List<SetLogsCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) => b.insertAll(setLogs, rows));
  }

  /// Children first, so no foreign key is ever left dangling.
  ///
  /// The seed does not come back afterwards: `seedIfEmpty` runs in
  /// `beforeOpen`, and a restore happens on an already-open database.
  Future<void> wipeAll() async {
    await delete(setLogs).go();
    await delete(workoutSessions).go();
    await delete(routineItems).go();
    await delete(routineBlocks).go();
    await delete(routineDays).go();
    await delete(routines).go();
    await delete(exercises).go();
  }
}
