import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/extensions/date_time_x.dart';
import '../../core/result/result.dart';
import '../../domain/entity/enums.dart';
import '../../domain/entity/set_log.dart';
import '../../domain/entity/workout_session.dart';
import '../../domain/repository/workout_repository.dart';
import '../database/app_database.dart';
import '../database/daos/routine_dao.dart';
import '../database/daos/workout_dao.dart';
import '../mapper/mappers.dart';
import 'data_errors.dart';

@LazySingleton(as: WorkoutRepository)
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._dao, this._routineDao, this._db);

  final WorkoutDao _dao;
  final RoutineDao _routineDao;
  final AppDatabase _db;

  @override
  Future<Result<WorkoutSession?>> getInProgressSession() =>
      runCatching(() async {
        final row = await _dao.findInProgress();
        if (row == null) return null;
        return _withLogs(row);
      });

  @override
  Future<Result<WorkoutSession>> startSession(int dayId) =>
      runCatching(() async {
        final day = await _routineDao.findDay(dayId);
        if (day == null) throw const NotFoundException('루틴 DAY를 찾을 수 없습니다.');

        // Only one session may be active. An older unfinished one is closed as
        // aborted rather than silently left behind.
        final stale = await _dao.findInProgress();
        if (stale != null) {
          await _dao.finishSession(
            stale.id,
            status: SessionStatus.aborted.name,
            endedAt: DateTime.now(),
          );
        }

        final now = DateTime.now();
        final id = await _dao.insertSession(
          WorkoutSessionsCompanion.insert(
            routineId: day.routineId,
            dayId: Value(day.id),
            dayCode: day.code,
            dayTitle: day.title,
            date: now.dateOnly,
            startedAt: now,
            status: Value(SessionStatus.inProgress.name),
          ),
        );

        final row = await _dao.findSession(id);
        if (row == null) throw const NotFoundException('세션 생성에 실패했습니다.');
        return row.toEntity();
      }, onError: classifyFailure);

  @override
  Future<Result<WorkoutSession>> getSession(int sessionId) =>
      runCatching(() => _loadSession(sessionId), onError: classifyFailure);

  @override
  Stream<WorkoutSession> watchSession(int sessionId) async* {
    yield await _loadSession(sessionId);
    final updates = _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.workoutSessions, _db.setLogs]),
    );
    await for (final _ in updates) {
      yield await _loadSession(sessionId);
    }
  }

  @override
  Future<Result<int>> logSet(SetLog log) =>
      runCatching(() => _dao.insertLog(log.toCompanion()));

  @override
  Future<Result<void>> updateSet(SetLog log) =>
      runCatching(() => _dao.updateLog(log.id, log.toCompanion()));

  @override
  Future<Result<void>> deleteSet(int setLogId) =>
      runCatching(() => _dao.deleteLog(setLogId));

  @override
  Future<Result<void>> completeSession(int sessionId, {String? memo}) =>
      runCatching(
        () => _dao.finishSession(
          sessionId,
          status: SessionStatus.completed.name,
          endedAt: DateTime.now(),
          memo: memo,
        ),
      );

  @override
  Future<Result<void>> abortSession(int sessionId) => runCatching(
    () => _dao.finishSession(
      sessionId,
      status: SessionStatus.aborted.name,
      endedAt: DateTime.now(),
    ),
  );

  @override
  Future<Result<void>> deleteSession(int sessionId) =>
      runCatching(() => _dao.deleteSession(sessionId));

  @override
  Future<Result<List<SetLog>>> getLastLogsForExercise(
    int exerciseId, {
    int limit = 6,
  }) => runCatching(() async {
    final rows = await _dao.lastLogsForExercise(exerciseId, limit);
    return rows.map((row) => row.toEntity()).toList();
  });

  // ── internals ───────────────────────────────────────────────────────────

  Future<WorkoutSession> _loadSession(int sessionId) async {
    final row = await _dao.findSession(sessionId);
    if (row == null) throw const NotFoundException('세션을 찾을 수 없습니다.');
    return _withLogs(row);
  }

  Future<WorkoutSession> _withLogs(WorkoutSessionRow row) async {
    final logs = await _dao.logsOf(row.id);
    return row.toEntity(setLogs: logs.map((l) => l.toEntity()).toList());
  }
}
