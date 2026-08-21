import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../../domain/entity/backup_package.dart';
import '../../domain/entity/enums.dart';
import '../../domain/repository/backup_repository.dart';
import '../../domain/repository/routine_repository.dart';
import '../database/app_database.dart';
import '../database/daos/backup_dao.dart';
import 'data_errors.dart';

/// Moves the whole database in and out of a `.json` file
/// (`docs/07-BACKUP.md`).
///
/// Routines are exported and imported through [RoutineRepository]: rebuilding a
/// routine graph is already solved there, and two copies of that code would
/// drift apart the first time a block field is added.
@LazySingleton(as: BackupRepository)
class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._dao, this._routines, this._db);

  final BackupDao _dao;
  final RoutineRepository _routines;
  final AppDatabase _db;

  @override
  Future<Result<BackupSummary>> summarize() => runCatching(() async {
    final counts = await _dao.counts();
    return BackupSummary(
      routineCount: counts.routines,
      exerciseCount: counts.exercises,
      sessionCount: counts.sessions,
      setCount: counts.sets,
      firstSessionDate: counts.first,
      lastSessionDate: counts.last,
    );
  }, onError: classifyFailure);

  @override
  Future<Result<BackupPackage>> exportBackup() =>
      runCatching(_exportBackup, onError: classifyFailure);

  @override
  Future<Result<BackupImportReport>> importBackup(
    BackupPackage package, {
    required BackupRestoreMode mode,
  }) => runCatching(
    () => _db.transaction(() => _importBackup(package, mode)),
    onError: classifyFailure,
  );

  // ── export ────────────────────────────────────────────────────────────────

  Future<BackupPackage> _exportBackup() async {
    final exerciseRows = await _dao.allExercises();
    final routineRows = await _dao.allRoutines();

    final routines = <BackupRoutine>[];
    for (final row in routineRows) {
      final exported = await _routines.exportRoutine(row.id);
      switch (exported) {
        case Ok(:final value):
          routines.add(BackupRoutine(package: value, isActive: row.isActive));
        case Err(:final failure):
          throw NotFoundException(failure.message);
      }
    }

    final sessionRows = await _dao.finishedSessions();
    final logRows = await _dao.logsOfSessions([
      for (final row in sessionRows) row.id,
    ]);
    final logsBySession = <int, List<SetLogDraft>>{};
    for (final log in logRows) {
      logsBySession.putIfAbsent(log.sessionId, () => []).add(
        SetLogDraft(
          exerciseName: log.exerciseName,
          bodyPart: BodyPart.fromName(log.bodyPart),
          blockLabel: log.blockLabel,
          itemOrder: log.itemOrder,
          setIndex: log.setIndex,
          weight: log.weight,
          reps: log.reps,
          durationSeconds: log.durationSeconds,
          rir: log.rir,
          restSeconds: log.restSeconds,
          isCompleted: log.isCompleted,
          completedAt: log.completedAt,
        ),
      );
    }

    // Sessions point at their routine by name; the row id means nothing on
    // another phone.
    final routineNameById = {for (final row in routineRows) row.id: row.name};

    return BackupPackage(
      exercises: [
        for (final row in exerciseRows)
          BackupExercise(
            name: row.name,
            bodyPart: BodyPart.fromName(row.bodyPart),
            subTarget: row.subTarget,
            equipment: row.equipment,
            isCustom: row.isCustom,
          ),
      ],
      routines: routines,
      sessions: [
        for (final row in sessionRows)
          SessionDraft(
            routineName: routineNameById[row.routineId],
            dayCode: row.dayCode,
            dayTitle: row.dayTitle,
            date: row.date,
            startedAt: row.startedAt,
            endedAt: row.endedAt,
            status: SessionStatus.fromName(row.status),
            memo: row.memo,
            sets: logsBySession[row.id] ?? const [],
          ),
      ],
    );
  }

  // ── import ────────────────────────────────────────────────────────────────

  Future<BackupImportReport> _importBackup(
    BackupPackage package,
    BackupRestoreMode mode,
  ) async {
    final warnings = <String>[];

    if (mode == BackupRestoreMode.replace) {
      // Never pull the floor out from under a workout that is happening now.
      if (await _dao.hasSessionInProgress()) {
        throw const ValidationException(
          '진행 중인 운동이 있어 덮어쓸 수 없습니다. 운동을 끝내거나 중단한 뒤 다시 시도하세요.',
        );
      }
      await _dao.wipeAll();
    }

    final exercises = await _restoreExercises(package);
    final routines = await _restoreRoutines(package, mode, warnings);
    final sessions = await _restoreSessions(package, mode, exercises, warnings);

    if (mode == BackupRestoreMode.replace) {
      final active = package.routines.where((r) => r.isActive).firstOrNull;
      final target = routines.idByName[active?.name] ?? routines.firstId;
      if (target != null) await _routines.setActiveRoutine(target);
    }

    return BackupImportReport(
      mode: mode,
      importedSessions: sessions.imported,
      skippedSessions: sessions.skipped,
      importedSets: sessions.sets,
      createdRoutines: routines.created,
      skippedRoutines: routines.skipped,
      reusedExercises: exercises.reused,
      createdExercises: exercises.created + sessions.createdExercises,
      warnings: warnings,
    );
  }

  /// The library first: routines and sets both look their exercises up by name,
  /// so every name in the file must exist as a row before either runs.
  Future<_ExerciseIndex> _restoreExercises(BackupPackage package) async {
    final idByName = <String, int>{
      for (final row in await _dao.allExercises()) row.name: row.id,
    };

    var reused = 0;
    var created = 0;
    for (final exercise in package.exercises) {
      if (idByName.containsKey(exercise.name)) {
        reused++;
        continue;
      }
      idByName[exercise.name] = await _dao.insertExercise(
        ExercisesCompanion.insert(
          name: exercise.name,
          bodyPart: exercise.bodyPart.name,
          subTarget: Value(exercise.subTarget),
          equipment: Value(exercise.equipment),
          isCustom: Value(exercise.isCustom),
        ),
      );
      created++;
    }
    return _ExerciseIndex(idByName, reused: reused, created: created);
  }

  /// A routine whose name is already taken is left alone — a merge must not
  /// undo edits made since the backup was written.
  Future<_RoutineIndex> _restoreRoutines(
    BackupPackage package,
    BackupRestoreMode mode,
    List<String> warnings,
  ) async {
    final idByName = <String, int>{
      for (final row in await _dao.allRoutines()) row.name: row.id,
    };

    var created = 0;
    var skipped = 0;
    for (final entry in package.routines) {
      if (idByName.containsKey(entry.name)) {
        skipped++;
        if (mode == BackupRestoreMode.merge) {
          warnings.add('루틴 "${entry.name}"은 이미 있어 그대로 두었습니다.');
        }
        continue;
      }

      final imported = await _routines.importRoutine(entry.package);
      switch (imported) {
        case Ok(:final value):
          idByName[entry.name] = value.routineId;
          warnings.addAll(value.warnings);
          created++;
        case Err(:final failure):
          // Abort the whole restore: half a backup is worse than none.
          throw ValidationException(
            '루틴 "${entry.name}"을 복원하지 못했습니다. ${failure.message}',
          );
      }
    }

    return _RoutineIndex(idByName, created: created, skipped: skipped);
  }

  Future<_SessionOutcome> _restoreSessions(
    BackupPackage package,
    BackupRestoreMode mode,
    _ExerciseIndex exercises,
    List<String> warnings,
  ) async {
    if (package.sessions.isEmpty) {
      return const _SessionOutcome(imported: 0, skipped: 0, sets: 0);
    }

    final existing = mode == BackupRestoreMode.merge
        ? await _dao.sessionStartTimes()
        : const <DateTime>{};

    // dayCode → row id, per routine. Loaded lazily; most backups reference one
    // or two routines.
    final dayIdsByRoutine = <int, Map<String, int>>{};
    final routineIdByName = <String, int>{
      for (final row in await _dao.allRoutines()) row.name: row.id,
    };

    var imported = 0;
    var skipped = 0;
    var setCount = 0;
    var createdExercises = 0;
    final missingRoutines = <String>{};
    final missingDays = <String>{};
    final invented = <String>{};

    for (final session in package.sessions) {
      if (existing.contains(session.startedAt)) {
        skipped++;
        continue;
      }

      final routineId = routineIdByName[session.routineName];
      if (session.routineName != null && routineId == null) {
        missingRoutines.add(session.routineName!);
      }

      int? dayId;
      if (routineId != null) {
        final days = dayIdsByRoutine[routineId] ??= {
          for (final row in await _dao.daysOf(routineId)) row.code: row.id,
        };
        dayId = days[session.dayCode];
        if (dayId == null) missingDays.add(session.dayCode);
      }

      final sessionId = await _dao.insertSession(
        WorkoutSessionsCompanion.insert(
          // Not a foreign key: 0 simply points at no routine, and the day
          // snapshot below keeps the record readable.
          routineId: routineId ?? 0,
          dayId: Value(dayId),
          dayCode: session.dayCode,
          dayTitle: session.dayTitle,
          date: session.date,
          startedAt: session.startedAt,
          endedAt: Value(session.endedAt),
          status: Value(session.status.name),
          memo: Value(session.memo),
        ),
      );

      final rows = <SetLogsCompanion>[];
      for (final set in session.sets) {
        var exerciseId = exercises.idByName[set.exerciseName];
        if (exerciseId == null) {
          // Only in history, never in a routine — the snapshot carries enough
          // to rebuild the library row so the trend graph still finds it.
          exerciseId = await _dao.insertExercise(
            ExercisesCompanion.insert(
              name: set.exerciseName,
              bodyPart: set.bodyPart.name,
              isCustom: const Value(true),
            ),
          );
          exercises.idByName[set.exerciseName] = exerciseId;
          createdExercises++;
          invented.add(set.exerciseName);
        }

        rows.add(
          SetLogsCompanion.insert(
            sessionId: sessionId,
            exerciseId: exerciseId,
            exerciseName: set.exerciseName,
            bodyPart: set.bodyPart.name,
            blockLabel: set.blockLabel,
            itemOrder: set.itemOrder,
            setIndex: set.setIndex,
            weight: Value(set.weight),
            reps: Value(set.reps),
            durationSeconds: Value(set.durationSeconds),
            rir: Value(set.rir),
            restSeconds: Value(set.restSeconds),
            isCompleted: Value(set.isCompleted),
            completedAt: set.completedAt,
          ),
        );
      }
      await _dao.insertSetLogs(rows);

      imported++;
      setCount += rows.length;
    }

    if (skipped > 0) {
      warnings.add('이미 있는 기록 $skipped개를 건너뛰었습니다.');
    }
    if (missingRoutines.isNotEmpty) {
      warnings.add(
        '루틴 ${missingRoutines.map((n) => '"$n"').join(" · ")}을 찾지 못해 '
        '해당 기록을 루틴 없이 넣었습니다.',
      );
    }
    if (missingDays.isNotEmpty) {
      warnings.add(
        'DAY ${missingDays.join(" · ")}을 루틴에서 찾지 못했습니다. '
        '기록은 그대로 남습니다.',
      );
    }
    if (invented.isNotEmpty) {
      warnings.add(
        '기록에만 있던 종목 ${invented.length}개를 종목 목록에 새로 만들었습니다.',
      );
    }

    return _SessionOutcome(
      imported: imported,
      skipped: skipped,
      sets: setCount,
      createdExercises: createdExercises,
    );
  }
}

class _ExerciseIndex {
  _ExerciseIndex(this.idByName, {required this.reused, required this.created});

  final Map<String, int> idByName;
  final int reused;
  final int created;
}

class _RoutineIndex {
  const _RoutineIndex(
    this.idByName, {
    required this.created,
    required this.skipped,
  });

  final Map<String, int> idByName;
  final int created;
  final int skipped;

  int? get firstId => idByName.values.firstOrNull;
}

class _SessionOutcome {
  const _SessionOutcome({
    required this.imported,
    required this.skipped,
    required this.sets,
    this.createdExercises = 0,
  });

  final int imported;
  final int skipped;
  final int sets;
  final int createdExercises;
}
