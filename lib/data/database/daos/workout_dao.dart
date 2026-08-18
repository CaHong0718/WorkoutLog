import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions, SetLogs, RoutineDays])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  Future<WorkoutSessionRow?> findInProgress() =>
      (select(workoutSessions)
            ..where((t) => t.status.equals('inProgress'))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<WorkoutSessionRow?> findSession(int sessionId) => (select(
    workoutSessions,
  )..where((t) => t.id.equals(sessionId))).getSingleOrNull();

  Future<int> insertSession(WorkoutSessionsCompanion companion) =>
      into(workoutSessions).insert(companion);

  Future<List<SetLogRow>> logsOf(int sessionId) =>
      (select(setLogs)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.itemOrder),
              (t) => OrderingTerm(expression: t.setIndex),
            ]))
          .get();

  Future<int> insertLog(SetLogsCompanion companion) =>
      into(setLogs).insert(companion);

  Future<void> updateLog(int id, SetLogsCompanion companion) =>
      (update(setLogs)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteLog(int id) =>
      (delete(setLogs)..where((t) => t.id.equals(id))).go();

  Future<void> finishSession(
    int sessionId, {
    required String status,
    required DateTime endedAt,
    String? memo,
  }) => (update(workoutSessions)..where((t) => t.id.equals(sessionId))).write(
    WorkoutSessionsCompanion(
      status: Value(status),
      endedAt: Value(endedAt),
      memo: memo == null ? const Value.absent() : Value(memo),
    ),
  );

  /// Set logs cascade away with the session row.
  Future<void> deleteSession(int sessionId) =>
      (delete(workoutSessions)..where((t) => t.id.equals(sessionId))).go();

  /// Completed sets for [exerciseId], newest first.
  Future<List<SetLogRow>> lastLogsForExercise(int exerciseId, int limit) =>
      (select(setLogs)
            ..where(
              (t) =>
                  t.exerciseId.equals(exerciseId) & t.isCompleted.equals(true),
            )
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.completedAt,
                mode: OrderingMode.desc,
              ),
              (t) => OrderingTerm(expression: t.setIndex),
            ])
            ..limit(limit))
          .get();
}
