import 'package:injectable/injectable.dart';

import '../../core/extensions/date_time_x.dart';
import '../../core/result/result.dart';
import '../../domain/entity/date_range.dart';
import '../../domain/entity/enums.dart';
import '../../domain/entity/exercise_progress_point.dart';
import '../../domain/entity/set_log.dart';
import '../../domain/entity/workout_session.dart';
import '../../domain/repository/history_repository.dart';
import '../database/app_database.dart';
import '../database/daos/history_dao.dart';
import '../mapper/mappers.dart';
import 'data_errors.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._dao);

  final HistoryDao _dao;

  @override
  Future<Result<List<WorkoutSession>>> getSessions(DateRange range) =>
      runCatching(() async {
        final rows = await _dao.sessionsBetween(range.start, range.end);
        return _attachLogs(rows);
      });

  @override
  Future<Result<WorkoutSession>> getSessionDetail(int sessionId) =>
      runCatching(() async {
        final row = await _dao.findSession(sessionId);
        if (row == null) throw const NotFoundException('세션을 찾을 수 없습니다.');
        final logs = await _dao.logsOfSessions([sessionId]);
        return row.toEntity(setLogs: logs.map((l) => l.toEntity()).toList());
      }, onError: classifyFailure);

  @override
  Future<Result<List<WorkoutSession>>> getSessionsOn(DateTime date) =>
      runCatching(() async {
        final rows = await _dao.sessionsOn(date.dateOnly);
        return _attachLogs(rows);
      });

  @override
  Future<Result<Map<BodyPart, int>>> getWeeklyVolume(
    DateTime anyDayInWeek,
  ) => runCatching(() async {
    final range = DateRange.week(anyDayInWeek);
    final raw = await _dao.volumeByBodyPart(range.start, range.end);
    return {
      for (final entry in raw.entries)
        BodyPart.fromName(entry.key): entry.value,
    };
  });

  @override
  Future<Result<List<ExerciseProgressPoint>>> getExerciseProgress(
    int exerciseId, {
    int limit = 30,
  }) => runCatching(() async {
    final rows = await _dao.exerciseHistory(exerciseId, limit);

    // Group by session date, then keep the heaviest set of each day.
    final byDate = <DateTime, List<SetLog>>{};
    for (final row in rows) {
      byDate.putIfAbsent(row.date, () => []).add(row.log.toEntity());
    }

    final points = <ExerciseProgressPoint>[];
    byDate.forEach((date, logs) {
      final weighted = logs.where((l) => l.weight != null).toList();
      if (weighted.isEmpty) return;
      weighted.sort((a, b) => b.weight!.compareTo(a.weight!));
      final top = weighted.first;
      points.add(
        ExerciseProgressPoint(
          date: date,
          topWeight: top.weight!,
          reps: top.reps ?? 0,
          totalVolume: logs.fold(0, (sum, l) => sum + l.volume),
        ),
      );
    });

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  });

  @override
  Future<Result<Set<DateTime>>> getWorkoutDates(DateRange range) =>
      runCatching(() async {
        final dates = await _dao.completedDates(range.start, range.end);
        return dates.map((d) => d.dateOnly).toSet();
      });

  @override
  Future<Result<int>> getTotalSessionCount() =>
      runCatching(_dao.totalCompletedSessions);

  Future<List<WorkoutSession>> _attachLogs(
    List<WorkoutSessionRow> rows,
  ) async {
    if (rows.isEmpty) return const [];
    final logs = await _dao.logsOfSessions(rows.map((r) => r.id).toList());
    final logsBySession = <int, List<SetLog>>{};
    for (final log in logs) {
      logsBySession.putIfAbsent(log.sessionId, () => []).add(log.toEntity());
    }
    return rows
        .map((row) => row.toEntity(setLogs: logsBySession[row.id] ?? const []))
        .toList();
  }
}
