import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/platform/routine_file_io.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/usecase/routine_usecases.dart';
import 'package:workout_log/presentation/routine_edit/bloc/routine_list_bloc.dart';
import 'package:workout_log/presentation/routine_edit/bloc/routine_list_effect.dart';
import 'package:workout_log/presentation/routine_edit/bloc/routine_list_intent.dart';
import 'package:workout_log/presentation/routine_edit/bloc/routine_list_state.dart';

/// Drives the routine library the way the screen does: bloc → use case →
/// repository → Drift, with only the platform file dialogs faked.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl repository;
  late _FakeFileIo fileIo;
  late RoutineListBloc bloc;

  const codec = RoutineCodec();

  const validFile = '''
{
  "format": "workout-log.routine",
  "version": 1,
  "routine": {
    "name": "상하체 2분할",
    "sessionMinutes": 50,
    "days": [
      {
        "code": "A", "title": "상체", "primaryBodyPart": "chest",
        "blocks": [{
          "label": "B1", "restSeconds": 150, "isCuttable": false,
          "items": [{
            "exercise": {"name": "케이블 크로스오버", "bodyPart": "chest"},
            "sets": 4, "repMin": 8, "repMax": 12
          }]
        }]
      }
    ]
  }
}
''';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoutineRepositoryImpl(db.routineDao, db);
    fileIo = _FakeFileIo();

    bloc = RoutineListBloc(
      WatchRoutines(repository),
      SetActiveRoutine(repository),
      CreateRoutine(repository),
      UpdateRoutine(repository),
      DeleteRoutine(repository),
      DuplicateRoutine(repository),
      const ParseRoutineFile(codec),
      ImportRoutine(repository),
      ExportRoutine(repository, codec),
      fileIo,
    );
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  Future<RoutineListState> loaded() {
    bloc.add(const LoadRoutines());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  Future<RoutineListState> awaitRoutines(int count) =>
      bloc.stream.firstWhere((s) => s.routines.length == count);

  test('루틴 목록은 시드 루틴 하나로 시작하고 그것이 활성이다', () async {
    final state = await loaded();

    expect(state.routines, hasLength(1));
    expect(state.active?.name, '무분할 40분');
    expect(state.canDelete, isFalse, reason: '하나뿐이면 삭제 불가');
  });

  test('새 루틴을 만들면 편집기를 여는 이펙트가 나온다', () async {
    await loaded();

    final effect = bloc.effects.first;
    bloc.add(
      const SaveRoutineMeta(
        Routine(id: Routine.unsavedId, name: '새 분할', sessionMinutes: 45),
      ),
    );

    expect(await effect, isA<OpenRoutineEditor>());

    final state = await awaitRoutines(2);
    expect(state.routines.last.name, '새 분할');
    expect(state.active?.name, '무분할 40분', reason: '만들어도 사용 중인 루틴은 그대로');
  });

  test('활성 전환은 정확히 하나만 활성으로 남긴다', () async {
    await loaded();
    bloc.add(
      const SaveRoutineMeta(
        Routine(id: Routine.unsavedId, name: '새 분할', sessionMinutes: 45),
      ),
    );
    final two = await awaitRoutines(2);
    final target = two.routines.firstWhere((r) => r.name == '새 분할');

    bloc.add(ActivateRoutine(target.id));
    final state = await bloc.stream.firstWhere(
      (s) => s.active?.id == target.id,
    );

    expect(state.routines.where((r) => r.isActive), hasLength(1));
  });

  group('가져오기', () {
    test('파일을 고르면 미리보기 이펙트가 나온다 — DB는 아직 그대로', () async {
      final before = await loaded();
      fileIo.nextPick = const PickedRoutineFile(
        fileName: '상하체.json',
        contents: validFile,
      );

      final effect = bloc.effects.first;
      bloc.add(const PickRoutineFile());

      final preview = await effect;
      expect(preview, isA<ShowImportPreview>());
      preview as ShowImportPreview;
      expect(preview.fileName, '상하체.json');
      expect(preview.parsed.package.name, '상하체 2분할');
      expect(preview.parsed.package.totalSets, 4);
      expect(bloc.state.routines, hasLength(before.routines.length));
    });

    test('미리보기를 확인해야 실제로 추가된다', () async {
      await loaded();
      final parsed = codec.decode(validFile).valueOrNull!;

      bloc.add(ConfirmImport(parsed.package));
      final state = await awaitRoutines(2);

      final imported = state.routines.firstWhere((r) => r.name == '상하체 2분할');
      expect(imported.dayCount, 1);
      expect(imported.weeklySets, 4);
      expect(imported.isActive, isFalse);
    });

    test('activate로 확인하면 바로 사용 중이 된다', () async {
      await loaded();
      final parsed = codec.decode(validFile).valueOrNull!;

      bloc.add(ConfirmImport(parsed.package, activate: true));
      final state = await bloc.stream.firstWhere(
        (s) => s.active?.name == '상하체 2분할',
      );

      expect(state.routines.where((r) => r.isActive), hasLength(1));
    });

    test('형식이 틀린 파일은 오류 목록을 이펙트로 돌려준다', () async {
      await loaded();
      fileIo.nextPick = const PickedRoutineFile(
        fileName: '오타.json',
        contents:
            '{"format": "workout-log.routine", "version": 1, "routine": '
            '{"name": "오타", "days": [{"code": "A", "title": "하체", '
            '"primaryBodyPart": "leg", "blocks": []}]}}',
      );

      final effect = bloc.effects.first;
      bloc.add(const PickRoutineFile());

      final result = await effect;
      expect(result, isA<ShowImportErrors>());
      result as ShowImportErrors;
      expect(result.fileName, '오타.json');
      expect(
        result.failure.errors.single,
        contains('routine.days[0].primaryBodyPart'),
      );
      expect(bloc.state.routines, hasLength(1), reason: 'DB는 건드리지 않는다');
    });

    test('파일 선택을 취소하면 아무 일도 일어나지 않는다', () async {
      await loaded();
      fileIo.nextPick = null;

      bloc.add(const PickRoutineFile());
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(bloc.state.routines, hasLength(1));
      expect(bloc.state.failure, isNull);
    });
  });

  group('내보내기', () {
    test('루틴 이름과 날짜로 만든 파일을 공유 시트에 넘긴다', () async {
      final state = await loaded();
      final seeded = state.routines.single;

      bloc.add(ShareRoutine(seeded.id));
      await bloc.stream.firstWhere((s) => !s.isBusy);

      expect(fileIo.sharedFileName, startsWith('무분할 40분_'));
      expect(fileIo.sharedFileName, endsWith('.json'));

      // What came out has to go back in.
      final reparsed = codec.decode(fileIo.sharedContents!).valueOrNull!;
      expect(reparsed.package.name, '무분할 40분');
      expect(reparsed.package.totalSets, 70);
    });

    test('공유가 실패하면 사용자에게 알린다', () async {
      final state = await loaded();
      fileIo.shareSucceeds = false;

      final effect = bloc.effects.first;
      bloc.add(ShareRoutine(state.routines.single.id));

      final message = await effect;
      expect(message, isA<ShowRoutineListMessage>());
    });
  });

  test('진행 중인 운동이 있는 루틴은 삭제를 거부하고 이유를 알린다', () async {
    final state = await loaded();
    final seeded = state.routines.single;

    bloc.add(
      const SaveRoutineMeta(
        Routine(id: Routine.unsavedId, name: '예비', sessionMinutes: 40),
      ),
    );
    await awaitRoutines(2);

    final day = (await repository.getDays(seeded.id)).valueOrNull!.first;
    await db.workoutDao.insertSession(
      WorkoutSessionsCompanion.insert(
        routineId: seeded.id,
        dayId: Value(day.id),
        dayCode: day.code,
        dayTitle: day.title,
        date: DateTime.now(),
        startedAt: DateTime.now(),
      ),
    );

    final effect = bloc.effects.first;
    bloc.add(RemoveRoutine(seeded.id));

    final message = await effect as ShowRoutineListMessage;
    expect(message.message, contains('진행 중'));
    expect(bloc.state.routines, hasLength(2));
  });

  test('공유로 들어온 파일도 같은 미리보기를 거친다', () async {
    await loaded();

    final effect = bloc.effects.first;
    bloc.add(const ReadRoutineSource(validFile, fileName: '카톡에서.json'));

    final preview = await effect as ShowImportPreview;
    expect(preview.fileName, '카톡에서.json');
    expect(preview.parsed.package.name, '상하체 2분할');
  });
}

/// Stands in for the system file picker and share sheet.
class _FakeFileIo implements RoutineFileIo {
  PickedRoutineFile? nextPick;
  bool shareSucceeds = true;

  String? sharedFileName;
  String? sharedContents;

  @override
  Future<PickedRoutineFile?> pickRoutineFile() async => nextPick;

  @override
  Future<PickedRoutineFile?> readFile(File file) async => nextPick;

  @override
  Future<bool> shareRoutineFile({
    required String fileName,
    required String contents,
  }) async {
    sharedFileName = fileName;
    sharedContents = contents;
    return shareSucceeds;
  }
}
