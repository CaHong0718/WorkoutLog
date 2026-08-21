import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/error/failure.dart';
import 'package:workout_log/core/extensions/date_time_x.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/exchange/backup_codec.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/data/repository/backup_repository_impl.dart';
import 'package:workout_log/data/repository/history_repository_impl.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/data/repository/workout_repository_impl.dart';
import 'package:workout_log/domain/entity/backup_package.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/entity/routine_day.dart';
import 'package:workout_log/domain/entity/set_log.dart';

/// Backup and restore against the real stack — codec → repository → Drift —
/// on an in-memory database seeded with the reference routine.
///
/// Format spec: `docs/07-BACKUP.md`.
void main() {
  // Every test stands up two phones at once — a source and a target — each on
  // its own in-memory executor. That is the point, not a mistake.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const routineCodec = RoutineCodec();
  const codec = BackupCodec(routineCodec);

  final today = DateTime.now().dateOnly;

  /// One phone: database plus the repositories the app wires to it.
  Future<
    ({
      AppDatabase db,
      RoutineRepositoryImpl routines,
      WorkoutRepositoryImpl workouts,
      BackupRepositoryImpl backups,
      Routine routine,
    })
  >
  makePhone() async {
    final db = AppDatabase(NativeDatabase.memory());
    final routines = RoutineRepositoryImpl(db.routineDao, db);
    final workouts = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    final backups = BackupRepositoryImpl(db.backupDao, routines, db);
    final routine = (await routines.getActiveRoutine()).valueOrNull!;
    return (
      db: db,
      routines: routines,
      workouts: workouts,
      backups: backups,
      routine: routine,
    );
  }

  RoutineDay dayOf(Routine routine, String code) =>
      routine.days.firstWhere((d) => d.code == code);

  /// Runs one workout and back-dates it, so a history can be built without
  /// touching the clock.
  Future<int> recordSession(
    ({
      AppDatabase db,
      RoutineRepositoryImpl routines,
      WorkoutRepositoryImpl workouts,
      BackupRepositoryImpl backups,
      Routine routine,
    })
    phone, {
    required String dayCode,
    required DateTime date,
    int sets = 3,
    bool complete = true,
  }) async {
    final day = dayOf(phone.routine, dayCode);
    final session = (await phone.workouts.startSession(day.id)).valueOrNull!;
    await (phone.db.update(
      phone.db.workoutSessions,
    )..where((t) => t.id.equals(session.id))).write(
      WorkoutSessionsCompanion(
        date: Value(date.dateOnly),
        startedAt: Value(date),
      ),
    );

    final item = day.blocks.first.items.first;
    for (var index = 1; index <= sets; index++) {
      await phone.workouts.logSet(
        SetLog(
          id: SetLog.unsavedId,
          sessionId: session.id,
          routineItemId: item.id,
          exerciseId: item.exerciseId,
          exerciseName: item.exercise.name,
          bodyPart: item.bodyPart,
          blockLabel: day.blocks.first.label,
          itemOrder: 0,
          setIndex: index,
          weight: 20 + index * 2.5,
          reps: 10,
          rir: 2,
          restSeconds: 90,
          completedAt: date.add(Duration(minutes: index)),
        ),
      );
    }
    if (complete) await phone.workouts.completeSession(session.id);
    return session.id;
  }

  BackupParseResult parse(String source) {
    final result = codec.decode(source);
    expect(
      result.valueOrNull,
      isNotNull,
      reason: (result.failureOrNull as RoutineFormatFailure?)?.errors.join('\n'),
    );
    return result.valueOrNull!;
  }

  Future<BackupPackage> exportOf(BackupRepositoryImpl repository) async {
    final result = await repository.exportBackup();
    expect(result.valueOrNull, isNotNull, reason: result.failureOrNull?.message);
    return result.valueOrNull!;
  }

  // ── round trip ──────────────────────────────────────────────────────────

  group('왕복', () {
    test('내보낸 백업을 새 기기에 덮어쓰면 기록이 그대로 살아난다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);
      await recordSession(
        source,
        dayCode: 'B',
        date: today.subtract(const Duration(days: 2)),
      );

      final original = await exportOf(source.backups);
      final file = codec.encode(original, exportedAt: DateTime(2026, 8, 21));

      final target = await makePhone();
      addTearDown(target.db.close);
      final parsed = parse(file);

      final report = await target.backups.importBackup(
        parsed.package,
        mode: BackupRestoreMode.replace,
      );
      expect(
        report.valueOrNull,
        isNotNull,
        reason: report.failureOrNull?.message,
      );
      expect(report.valueOrNull!.importedSessions, 2);
      expect(report.valueOrNull!.importedSets, 6);

      expect(await exportOf(target.backups), original);
    });

    test('복원한 기기에서도 활성 루틴과 순번이 이어진다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);

      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.replace,
      );

      final active = (await target.routines.getActiveRoutine()).valueOrNull!;
      expect(active.name, source.routine.name);

      // A was the last day recorded, so the rotation offers B next.
      final next = (await target.routines.getNextDay()).valueOrNull!;
      expect(next.code, 'B');
    });

    test('재설치 시나리오 — 시드만 있는 기기에 합치면 루틴은 그대로, 기록만 들어온다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);

      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      final before = (await target.backups.summarize()).valueOrNull!;
      expect(before.sessionCount, 0);

      final report = (await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.merge,
      )).valueOrNull!;

      expect(report.createdRoutines, 0, reason: '같은 이름의 시드 루틴을 재사용한다');
      expect(report.skippedRoutines, 1);
      expect(report.createdExercises, 0, reason: '시드 종목이 이름으로 대조된다');
      expect(report.importedSessions, 1);

      final after = (await target.backups.summarize()).valueOrNull!;
      expect(after.routineCount, before.routineCount);
      expect(after.exerciseCount, before.exerciseCount);
      expect(after.sessionCount, 1);
      expect(after.setCount, 3);
    });
  });

  // ── merge ───────────────────────────────────────────────────────────────

  group('합치기', () {
    test('같은 백업을 두 번 넣어도 기록이 겹치지 않는다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);
      await recordSession(
        source,
        dayCode: 'B',
        date: today.subtract(const Duration(days: 2)),
      );
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await target.backups.importBackup(package, mode: BackupRestoreMode.merge);
      final second = (await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.merge,
      )).valueOrNull!;

      expect(second.importedSessions, 0);
      expect(second.skippedSessions, 2);
      expect((await target.backups.summarize()).valueOrNull!.sessionCount, 2);
    });

    test('합치기는 기존 기록을 지우지 않는다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await recordSession(
        target,
        dayCode: 'C',
        date: today.subtract(const Duration(days: 5)),
      );

      await target.backups.importBackup(package, mode: BackupRestoreMode.merge);
      expect((await target.backups.summarize()).valueOrNull!.sessionCount, 2);
    });

    test('진행 중인 운동이 있어도 합치기는 된다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      await recordSession(source, dayCode: 'A', date: today);
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await recordSession(
        target,
        dayCode: 'B',
        date: today,
        complete: false,
      );

      final report = await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.merge,
      );
      expect(report.valueOrNull, isNotNull, reason: report.failureOrNull?.message);
    });

    test('기록에만 있는 종목은 종목 목록에 새로 만들어 무게 추이를 잇는다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      final package = BackupPackage(
        sessions: [
          SessionDraft(
            dayCode: 'X',
            dayTitle: '외부 기록',
            date: today,
            startedAt: today.add(const Duration(hours: 19)),
            sets: [
              SetLogDraft(
                exerciseName: '케틀벨 스윙',
                bodyPart: BodyPart.legs,
                blockLabel: 'B1',
                itemOrder: 0,
                setIndex: 1,
                weight: 24,
                reps: 15,
                completedAt: today.add(const Duration(hours: 19, minutes: 3)),
              ),
            ],
          ),
        ],
      );

      final report = (await source.backups.importBackup(
        package,
        mode: BackupRestoreMode.merge,
      )).valueOrNull!;
      expect(report.createdExercises, 1);

      final history = HistoryRepositoryImpl(source.db.historyDao);
      final volume = (await history.getWeeklyVolume(today)).valueOrNull!;
      expect(volume[BodyPart.legs], 1, reason: '부위 스냅샷으로 주간 볼륨에 잡힌다');
    });
  });

  // ── replace ─────────────────────────────────────────────────────────────

  group('덮어쓰기', () {
    test('진행 중인 운동이 있으면 거부한다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await recordSession(target, dayCode: 'A', date: today, complete: false);

      final report = await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.replace,
      );
      expect(report.failureOrNull, isA<ValidationFailure>());
      expect(report.failureOrNull!.message, contains('진행 중인 운동'));
    });

    test('덮어쓰면 백업에 없던 기록은 사라진다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await recordSession(target, dayCode: 'A', date: today);
      expect((await target.backups.summarize()).valueOrNull!.sessionCount, 1);

      await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.replace,
      );
      expect((await target.backups.summarize()).valueOrNull!.sessionCount, 0);
    });

    test('시드가 다시 깔리지 않는다 — 루틴은 백업에 담긴 것뿐이다', () async {
      final source = await makePhone();
      addTearDown(source.db.close);
      final package = await exportOf(source.backups);

      final target = await makePhone();
      addTearDown(target.db.close);
      await target.backups.importBackup(
        package,
        mode: BackupRestoreMode.replace,
      );

      expect((await target.backups.summarize()).valueOrNull!.routineCount, 1);
    });
  });

  // ── file format ─────────────────────────────────────────────────────────

  group('파일 형식', () {
    test('진행 중인 세션은 내보내지 않는다', () async {
      final phone = await makePhone();
      addTearDown(phone.db.close);
      await recordSession(phone, dayCode: 'A', date: today, complete: false);

      expect((await exportOf(phone.backups)).sessions, isEmpty);
    });

    test('진행 중 상태가 담긴 파일은 거부한다', () {
      final result = codec.decode(
        '{"format": "workout-log.backup", "version": 1, "sessions": ['
        '{"dayCode": "A", "dayTitle": "등", "date": "2026-08-18", '
        '"startedAt": "2026-08-18T19:00:00.000", "status": "inProgress"}]}',
      );
      final failure = result.failureOrNull as RoutineFormatFailure;
      expect(failure.errors.single, contains('sessions[0].status'));
    });

    test('루틴 파일을 백업으로 열면 어디로 가야 하는지 알려준다', () async {
      final phone = await makePhone();
      addTearDown(phone.db.close);
      final routineFile = routineCodec.encode(
        (await phone.routines.exportRoutine(phone.routine.id)).valueOrNull!,
      );

      final failure = codec.decode(routineFile).failureOrNull;
      expect(failure, isA<RoutineFormatFailure>());
      expect(
        (failure! as RoutineFormatFailure).errors.first,
        contains('루틴 목록의 가져오기'),
      );
    });

    test('문제를 첫 번째에서 멈추지 않고 경로와 함께 모아 보고한다', () {
      final result = codec.decode(
        '{"format": "workout-log.backup", "version": 1, "sessions": ['
        '{"dayCode": "A", "dayTitle": "등", "date": "어제", '
        '"startedAt": "2026-08-18T19:00:00.000", "sets": ['
        '{"exercise": "풀업", "bodyPart": "back", "blockLabel": "B1", '
        '"itemOrder": 0, "setIndex": 0, "completedAt": "2026-08-18T19:05:00.000"}'
        ']}]}',
      );
      final errors = (result.failureOrNull as RoutineFormatFailure).errors;
      expect(errors, hasLength(2));
      expect(errors, contains(startsWith('sessions[0].date')));
      expect(errors, contains(startsWith('sessions[0].sets[0].setIndex')));
    });

    test('백업 안의 루틴은 루틴 파일과 같은 스키마다', () async {
      final phone = await makePhone();
      addTearDown(phone.db.close);
      final package = await exportOf(phone.backups);

      final body = routineCodec.encodeRoutineBody(package.routines.single.package);
      final reparsed = routineCodec.decodeRoutineBody(body, path: 'routines[0]');
      expect(reparsed.errors, isEmpty);
      expect(reparsed.package, package.routines.single.package);
    });

    test('사용 중 루틴이 여럿이면 첫 번째만 살리고 경고한다', () {
      final result = codec.decode(
        '{"format": "workout-log.backup", "version": 1, "routines": ['
        '{"name": "하나", "isActive": true, "days": [{"code": "A", "title": "등", '
        '"primaryBodyPart": "back", "blocks": []}]},'
        '{"name": "둘", "isActive": true, "days": [{"code": "A", "title": "등", '
        '"primaryBodyPart": "back", "blocks": []}]}]}',
      );
      final package = result.valueOrNull!.package;
      expect(package.routines.map((r) => r.isActive), [true, false]);
      expect(result.valueOrNull!.warnings.single, contains('routines[1]'));
    });

    test('파일명은 날짜로 만든다', () {
      expect(codec.fileNameFor(DateTime(2026, 8, 21)), '운동기록_20260821.json');
    });

    test('빈 백업도 유효하다', () {
      final parsed = parse('{"format": "workout-log.backup", "version": 1}');
      expect(parsed.package.sessions, isEmpty);
      expect(parsed.package.routines, isEmpty);
    });
  });
}
