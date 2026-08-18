import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'history_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions, SetLogs])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  Future<List<WorkoutSessionRow>> sessionsBetween(
    DateTime start,
    DateTime end,
  ) =>
      (select(workoutSessions)
            ..where((t) => t.date.isBetweenValues(start, end))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<WorkoutSessionRow?> findSession(int sessionId) => (select(
    workoutSessions,
  )..where((t) => t.id.equals(sessionId))).getSingleOrNull();

  Future<List<WorkoutSessionRow>> sessionsOn(DateTime date) =>
      (select(workoutSessions)
            ..where((t) => t.date.equals(date))
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .get();

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

  /// Completed set counts per body part within a date window.
  Future<Map<String, int>> volumeByBodyPart(
    DateTime start,
    DateTime end,
  ) async {
    final setCount = setLogs.id.count();
    final query = selectOnly(setLogs)
      ..addColumns([setLogs.bodyPart, setCount])
      ..join([
        innerJoin(
          workoutSessions,
          workoutSessions.id.equalsExp(setLogs.sessionId),
        ),
      ])
      ..where(
        setLogs.isCompleted.equals(true) &
            workoutSessions.date.isBetweenValues(start, end),
      )
      ..groupBy([setLogs.bodyPart]);

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read(setLogs.bodyPart)!: row.read(setCount) ?? 0,
    };
  }

  /// Completed logs for one exercise joined with their session date,
  /// newest session first.
  Future<List<({DateTime date, SetLogRow log})>> exerciseHistory(
    int exerciseId,
    int sessionLimit,
  ) async {
    final query =
        select(setLogs).join([
            innerJoin(
              workoutSessions,
              workoutSessions.id.equalsExp(setLogs.sessionId),
            ),
          ])
          ..where(
            setLogs.exerciseId.equals(exerciseId) &
                setLogs.isCompleted.equals(true),
          )
          ..orderBy([
            OrderingTerm(
              expression: workoutSessions.date,
              mode: OrderingMode.desc,
            ),
          ]);

    final rows = await query.get();
    final result = <({DateTime date, SetLogRow log})>[];
    final seenDates = <DateTime>{};

    for (final row in rows) {
      final date = row.readTable(workoutSessions).date;
      if (!seenDates.contains(date) && seenDates.length >= sessionLimit) {
        continue;
      }
      seenDates.add(date);
      result.add((date: date, log: row.readTable(setLogs)));
    }
    return result;
  }

  Future<List<DateTime>> completedDates(DateTime start, DateTime end) async {
    final query = selectOnly(workoutSessions, distinct: true)
      ..addColumns([workoutSessions.date])
      ..where(
        workoutSessions.status.equals('completed') &
            workoutSessions.date.isBetweenValues(start, end),
      );
    final rows = await query.get();
    return rows
        .map((row) => row.read(workoutSessions.date))
        .whereType<DateTime>()
        .toList();
  }

  Future<int> totalCompletedSessions() async {
    final counter = workoutSessions.id.count();
    final query = selectOnly(workoutSessions)
      ..addColumns([counter])
      ..where(workoutSessions.status.equals('completed'));
    final row = await query.getSingle();
    return row.read(counter) ?? 0;
  }
}
