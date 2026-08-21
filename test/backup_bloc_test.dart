import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/extensions/date_time_x.dart';
import 'package:workout_log/core/platform/json_file_io.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/exchange/backup_codec.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/data/repository/backup_repository_impl.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/data/repository/workout_repository_impl.dart';
import 'package:workout_log/domain/entity/backup_package.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/entity/set_log.dart';
import 'package:workout_log/domain/usecase/backup_usecases.dart';
import 'package:workout_log/presentation/backup/bloc/backup_bloc.dart';
import 'package:workout_log/presentation/backup/bloc/backup_effect.dart';
import 'package:workout_log/presentation/backup/bloc/backup_intent.dart';
import 'package:workout_log/presentation/backup/bloc/backup_state.dart';

import 'fake_file_io.dart';

/// Drives the backup screen the way the user does: bloc → use case →
/// repository → Drift, with only the platform file dialogs faked.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl routines;
  late WorkoutRepositoryImpl workouts;
  late BackupRepositoryImpl backups;
  late FakeFileIo fileIo;
  late BackupBloc bloc;
  late Routine routine;

  const codec = BackupCodec(RoutineCodec());
  final today = DateTime.now().dateOnly;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routines = RoutineRepositoryImpl(db.routineDao, db);
    workouts = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    backups = BackupRepositoryImpl(db.backupDao, routines, db);
    fileIo = FakeFileIo();
    routine = (await routines.getActiveRoutine()).valueOrNull!;

    bloc = BackupBloc(
      GetBackupSummary(backups),
      const ParseBackupFile(codec),
      ExportBackup(backups, codec),
      ImportBackup(backups),
      fileIo,
    );
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  Future<void> recordSession({int sets = 3}) async {
    final day = routine.days.first;
    final session = (await workouts.startSession(day.id)).valueOrNull!;
    await (db.update(
      db.workoutSessions,
    )..where((t) => t.id.equals(session.id))).write(
      WorkoutSessionsCompanion(date: Value(today), startedAt: Value(today)),
    );

    final item = day.blocks.first.items.first;
    for (var index = 1; index <= sets; index++) {
      await workouts.logSet(
        SetLog(
          id: SetLog.unsavedId,
          sessionId: session.id,
          exerciseId: item.exerciseId,
          exerciseName: item.exercise.name,
          bodyPart: item.bodyPart,
          blockLabel: day.blocks.first.label,
          itemOrder: 0,
          setIndex: index,
          weight: 40,
          reps: 10,
          completedAt: today.add(Duration(minutes: index)),
        ),
      );
    }
    await workouts.completeSession(session.id);
  }

  Future<BackupState> load() {
    bloc.add(const LoadBackupSummary());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  group('요약', () {
    test('기록이 없으면 내보낼 것이 없다고 본다', () async {
      final state = await load();
      expect(state.isEmpty, isTrue);
      expect(state.summary.routineCount, 1, reason: '시드 루틴은 있다');
    });

    test('기록을 남기면 요약이 그 수를 센다', () async {
      await recordSession();
      final state = await load();

      expect(state.isEmpty, isFalse);
      expect(state.summary.sessionCount, 1);
      expect(state.summary.setCount, 3);
      expect(state.summary.firstSessionDate, today);
    });
  });

  group('내보내기', () {
    test('공유 시트에 날짜가 붙은 파일이 올라간다', () async {
      await recordSession();
      await load();

      bloc.add(const ShareBackupFile());
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(fileIo.sharedFileName, matches(r'^운동기록_\d{8}\.json$'));
      final parsed = codec.decode(fileIo.sharedContents!).valueOrNull!;
      expect(parsed.package.sessions, hasLength(1));
      expect(parsed.package.routines, hasLength(1));
    });
  });

  group('복원', () {
    /// A file produced by another phone: one session, exported and reset.
    Future<String> otherPhoneBackup() async {
      await recordSession();
      final package = (await backups.exportBackup()).valueOrNull!;
      await db.backupDao.wipeAll();
      return codec.encode(package, exportedAt: DateTime(2026, 8, 21));
    }

    test('고른 파일은 바로 쓰이지 않고 미리보기로 먼저 온다', () async {
      final file = await otherPhoneBackup();
      await load();

      fileIo.nextPick = PickedJsonFile(
        fileName: '운동기록_20260821.json',
        contents: file,
      );

      final effect = bloc.effects.first;
      bloc.add(const PickBackupFile());

      final shown = await effect;
      expect(shown, isA<ShowRestorePreview>());
      expect(
        (shown as ShowRestorePreview).parsed.package.sessions,
        hasLength(1),
      );
      expect(
        (await backups.summarize()).valueOrNull!.sessionCount,
        0,
        reason: '확인 전에는 아무것도 쓰지 않는다',
      );
    });

    test('확인하면 기록이 들어오고 요약이 따라 갱신된다', () async {
      final file = await otherPhoneBackup();
      await load();

      final package = codec.decode(file).valueOrNull!.package;
      bloc.add(ConfirmRestore(package, mode: BackupRestoreMode.merge));

      final state = await bloc.stream.firstWhere(
        (s) => !s.isBusy && !s.isLoading && s.summary.sessionCount > 0,
      );
      expect(state.summary.sessionCount, 1);
      expect(state.summary.setCount, 3);
    });

    test('읽을 수 없는 파일은 오류 목록으로 돌아온다', () async {
      await load();
      fileIo.nextPick = const PickedJsonFile(
        fileName: '이상한.json',
        contents: '{"format": "workout-log.backup", "version": 9}',
      );

      final effect = bloc.effects.first;
      bloc.add(const PickBackupFile());

      final shown = await effect;
      expect(shown, isA<ShowRestoreErrors>());
      expect(
        (shown as ShowRestoreErrors).failure.errors.single,
        contains('version'),
      );
    });

    test('파일 선택을 취소하면 아무 일도 일어나지 않는다', () async {
      await load();
      fileIo.nextPick = null;

      bloc.add(const PickBackupFile());
      final state = await bloc.stream.firstWhere((s) => !s.isBusy);
      expect(state.summary.sessionCount, 0);
    });
  });
}
