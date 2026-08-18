import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/error/failure.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/entity/routine_package.dart';

/// Exercises the exchange format end to end on a real (in-memory) database:
/// codec → repository → Drift, the same path the app takes.
///
/// Format spec: `docs/04-ROUTINE-EXCHANGE.md`.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl repository;
  const codec = RoutineCodec();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoutineRepositoryImpl(db.routineDao, db);
  });

  tearDown(() => db.close());

  Future<Routine> activeRoutine() async {
    final result = await repository.getActiveRoutine();
    expect(
      result.valueOrNull,
      isNotNull,
      reason: result.failureOrNull?.message,
    );
    return result.valueOrNull!;
  }

  Future<RoutinePackage> exportOf(int routineId) async {
    final result = await repository.exportRoutine(routineId);
    expect(
      result.valueOrNull,
      isNotNull,
      reason: result.failureOrNull?.message,
    );
    return result.valueOrNull!;
  }

  RoutineParseResult parse(String source) {
    final result = codec.decode(source);
    expect(
      result.valueOrNull,
      isNotNull,
      reason: (result.failureOrNull as RoutineFormatFailure?)?.errors.join(
        '\n',
      ),
    );
    return result.valueOrNull!;
  }

  /// Builds a minimal valid document around [routineBody].
  String document(String routineBody) =>
      '{"format": "workout-log.routine", "version": 1, "routine": $routineBody}';

  // ── round trip ──────────────────────────────────────────────────────────

  group('왕복', () {
    test('시드 루틴을 내보냈다 다시 가져오면 그래프가 동일하다', () async {
      final seeded = await activeRoutine();
      final original = await exportOf(seeded.id);

      final json = codec.encode(original, exportedAt: DateTime(2026, 8, 11));
      final parsed = parse(json);
      expect(parsed.warnings, isEmpty);

      final report = await repository.importRoutine(parsed.package);
      expect(
        report.valueOrNull,
        isNotNull,
        reason: report.failureOrNull?.message,
      );

      final reimported = await exportOf(report.valueOrNull!.routineId);
      expect(reimported, original);
    });

    test('왕복해도 주간 볼륨이 70세트 그대로다', () async {
      final seeded = await activeRoutine();
      final parsed = parse(codec.encode(await exportOf(seeded.id)));
      final report = await repository.importRoutine(parsed.package);

      final routines = (await repository.getRoutines()).valueOrNull!;
      final copy = routines.firstWhere(
        (r) => r.id == report.valueOrNull!.routineId,
      );

      expect(copy.weeklySets, 70);
      expect(copy.weeklyVolumeByBodyPart[BodyPart.shoulder], 19);
      expect(copy.weeklyVolumeByBodyPart[BodyPart.chest], 17);
      expect(copy.weeklyVolumeByBodyPart[BodyPart.back], 16);
      expect(copy.weeklyVolumeByBodyPart[BodyPart.legs], 12);
      expect(copy.weeklyVolumeByBodyPart[BodyPart.arms], 6);
    });

    test('같은 이름의 종목은 재사용되고 새 행을 만들지 않는다', () async {
      final seeded = await activeRoutine();
      final before = (await db.exerciseDao.getAll()).length;

      final parsed = parse(codec.encode(await exportOf(seeded.id)));
      final report = (await repository.importRoutine(
        parsed.package,
      )).valueOrNull!;

      expect(report.createdExercises, 0);
      expect(report.reusedExercises, greaterThan(0));
      expect((await db.exerciseDao.getAll()).length, before);
    });

    test('새 종목만 커스텀으로 추가된다', () async {
      final parsed = parse(
        document('''
        {
          "name": "신규 루틴",
          "days": [{
            "code": "A", "title": "가슴", "primaryBodyPart": "chest",
            "blocks": [{
              "label": "B1", "restSeconds": 120,
              "items": [
                {"exercise": {"name": "티바로우", "bodyPart": "back"},
                 "sets": 3, "repMin": 8, "repMax": 10},
                {"exercise": {"name": "케이블 크로스오버", "bodyPart": "chest"},
                 "sets": 3, "repMin": 12, "repMax": 15}
              ]
            }]
          }]
        }'''),
      );

      final report = (await repository.importRoutine(
        parsed.package,
      )).valueOrNull!;

      // 티바로우 is seeded; 케이블 크로스오버 is not.
      expect(report.reusedExercises, 1);
      expect(report.createdExercises, 1);

      final added = await db.exerciseDao.byName('케이블 크로스오버');
      expect(added, isNotNull);
      expect(added!.isCustom, isTrue);
      expect(added.bodyPart, BodyPart.chest.name);
    });
  });

  // ── validation ──────────────────────────────────────────────────────────

  group('검증', () {
    RoutineFormatFailure failureOf(String source) {
      final result = codec.decode(source);
      expect(result.isErr, isTrue, reason: '오류로 보고되어야 합니다');
      return result.failureOrNull! as RoutineFormatFailure;
    }

    test('format이 다르면 거부한다', () {
      final failure = failureOf('{"format": "something-else", "version": 1}');
      expect(failure.errors.join(), contains('format'));
    });

    test('알 수 없는 enum은 기본값으로 떨어뜨리지 않고 오류로 보고한다', () {
      final failure = failureOf(
        document('''
        {"name": "오타", "days": [
          {"code": "A", "title": "하체", "primaryBodyPart": "leg", "blocks": []}
        ]}'''),
      );

      expect(
        failure.errors.single,
        allOf(contains('routine.days[0].primaryBodyPart'), contains('"leg"')),
      );
    });

    test('오류 위치를 경로로 찍고 여러 개를 한 번에 모은다', () {
      final failure = failureOf(
        document('''
        {"name": "여러 오류", "days": [
          {"code": "A", "title": "가슴", "primaryBodyPart": "chest", "blocks": [
            {"label": "B1", "restSeconds": 120, "items": [
              {"exercise": {"name": "벤치프레스", "bodyPart": "chest"},
               "sets": 3, "repMin": 12, "repMax": 8},
              {"exercise": {"name": "딥스", "bodyPart": "chest"},
               "sets": 0, "repMin": 8, "repMax": 10}
            ]}
          ]}
        ]}'''),
      );

      expect(failure.errors, hasLength(2));
      expect(
        failure.errors.first,
        contains('routine.days[0].blocks[0].items[0].repMax'),
      );
      expect(
        failure.errors.last,
        contains('routine.days[0].blocks[0].items[1].sets'),
      );
    });

    test('duration 슬롯은 durationSeconds가 없으면 오류다', () {
      final failure = failureOf(
        document('''
        {"name": "복근", "days": [
          {"code": "A", "title": "복근", "primaryBodyPart": "abs", "blocks": [
            {"label": "복근", "restSeconds": 0, "items": [
              {"exercise": {"name": "행잉 레그 레이즈", "bodyPart": "abs"},
               "sets": 1, "repMode": "duration"}
            ]}
          ]}
        ]}'''),
      );

      expect(failure.errors.join(), contains('durationSeconds'));
    });

    test('JSON 자체가 깨졌으면 읽기 전에 멈춘다', () {
      final failure = failureOf('{"format": ');
      expect(failure.message, 'JSON을 읽을 수 없습니다.');
    });

    test('검증에 실패하면 DB를 건드리지 않는다', () async {
      final before = (await repository.getRoutines()).valueOrNull!.length;
      failureOf(document('{"name": "빈 날", "days": []}'));
      expect((await repository.getRoutines()).valueOrNull!.length, before);
    });
  });

  // ── lenient rules ───────────────────────────────────────────────────────

  group('경고', () {
    test('슈퍼세트 세트 수가 라운드 수와 다르면 맞추고 경고한다', () {
      final parsed = parse(
        document('''
        {"name": "슈퍼세트", "days": [
          {"code": "A", "title": "어깨", "primaryBodyPart": "shoulder", "blocks": [
            {"label": "B3", "type": "superset", "rounds": 3, "restSeconds": 90,
             "items": [
               {"exercise": {"name": "사이드 레터럴 라이즈", "bodyPart": "shoulder"},
                "sets": 5, "repMin": 12, "repMax": 15},
               {"exercise": {"name": "페이스 풀", "bodyPart": "shoulder"},
                "sets": 3, "repMin": 12, "repMax": 15}
             ]}
          ]}
        ]}'''),
      );

      final block = parsed.package.days.single.blocks.single;
      expect(block.items.map((i) => i.sets), everyElement(3));
      expect(parsed.warnings.single, contains('사이드 레터럴 라이즈'));
    });

    test('찾을 수 없는 대체 종목은 경고만 남기고 가져오기는 성공한다', () async {
      final parsed = parse(
        document('''
        {"name": "대체 종목", "days": [
          {"code": "A", "title": "등", "primaryBodyPart": "back", "blocks": [
            {"label": "B1", "restSeconds": 120, "items": [
              {"exercise": {"name": "티바로우", "bodyPart": "back"},
               "sets": 3, "repMin": 8, "repMax": 10,
               "alternatives": ["시티드 케이블 로우", "존재하지 않는 종목"]}
            ]}
          ]}
        ]}'''),
      );
      expect(parsed.warnings, isEmpty, reason: '파싱 단계에서는 라이브러리를 모른다');

      final report = (await repository.importRoutine(
        parsed.package,
      )).valueOrNull!;
      expect(report.warnings.single, contains('존재하지 않는 종목'));

      final routines = (await repository.getRoutines()).valueOrNull!;
      final imported = routines.firstWhere((r) => r.id == report.routineId);
      final item = imported.days.single.blocks.single.items.single;
      expect(item.alternativeExerciseIds, hasLength(1));
    });

    test('종목 이름만 쓴 축약형은 파일 안의 정의로 해석된다', () {
      final parsed = parse(
        document('''
        {"name": "축약형", "days": [
          {"code": "A", "title": "등", "primaryBodyPart": "back", "blocks": [
            {"label": "B1", "restSeconds": 120, "items": [
              {"exercise": {"name": "티바로우", "bodyPart": "back", "equipment": "바벨"},
               "sets": 3, "repMin": 8, "repMax": 10}
            ]},
            {"label": "B2", "restSeconds": 90, "items": [
              {"exercise": "티바로우", "sets": 2, "repMax": 12}
            ]}
          ]}
        ]}'''),
      );

      final second = parsed.package.days.single.blocks[1].items.single;
      expect(second.exercise.bodyPart, BodyPart.back);
      expect(second.exercise.equipment, '바벨');
      // A single bound is enough — it fills both sides.
      expect(second.repMin, 12);
      expect(second.repMax, 12);
    });

    test('정의되지 않은 이름만 쓰면 부위를 알 수 없어 오류다', () {
      final result = codec.decode(
        document('''
        {"name": "축약형", "days": [
          {"code": "A", "title": "등", "primaryBodyPart": "back", "blocks": [
            {"label": "B1", "restSeconds": 120, "items": [
              {"exercise": "정체불명", "sets": 3, "repMin": 8, "repMax": 10}
            ]}
          ]}
        ]}'''),
      );

      expect(result.isErr, isTrue);
      expect(
        (result.failureOrNull! as RoutineFormatFailure).errors.join(),
        contains('bodyPart'),
      );
    });
  });

  // ── routine library ─────────────────────────────────────────────────────

  group('루틴 관리', () {
    Future<int> importSimple({
      String name = '두 번째 루틴',
      bool activate = false,
    }) async {
      final parsed = parse(
        document('''
        {"name": "$name", "days": [
          {"code": "A", "title": "전신", "primaryBodyPart": "legs", "blocks": [
            {"label": "B1", "restSeconds": 120, "items": [
              {"exercise": {"name": "레그 프레스", "bodyPart": "legs"},
               "sets": 3, "repMin": 8, "repMax": 12}
            ]}
          ]}
        ]}'''),
      );
      final report = await repository.importRoutine(
        parsed.package,
        activate: activate,
      );
      expect(
        report.valueOrNull,
        isNotNull,
        reason: report.failureOrNull?.message,
      );
      return report.valueOrNull!.routineId;
    }

    test('가져오기는 기본적으로 활성 루틴을 바꾸지 않는다', () async {
      final before = await activeRoutine();
      await importSimple();

      expect((await activeRoutine()).id, before.id);
      expect((await repository.getRoutines()).valueOrNull, hasLength(2));
    });

    test('activate로 가져오면 그 루틴이 활성이 된다', () async {
      final id = await importSimple(activate: true);
      expect((await activeRoutine()).id, id);
    });

    test('활성 루틴은 항상 하나뿐이다', () async {
      final second = await importSimple();
      await repository.setActiveRoutine(second);

      final routines = (await repository.getRoutines()).valueOrNull!;
      expect(routines.where((r) => r.isActive), hasLength(1));
      expect(routines.firstWhere((r) => r.isActive).id, second);
    });

    test('마지막 남은 루틴은 삭제할 수 없다', () async {
      final seeded = await activeRoutine();
      final result = await repository.deleteRoutine(seeded.id);

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect((await repository.getRoutines()).valueOrNull, hasLength(1));
    });

    test('진행 중인 운동이 있는 루틴은 삭제할 수 없다', () async {
      final seeded = await activeRoutine();
      await importSimple();

      await db.workoutDao.insertSession(
        WorkoutSessionsCompanion.insert(
          routineId: seeded.id,
          dayId: Value(seeded.days.first.id),
          dayCode: seeded.days.first.code,
          dayTitle: seeded.days.first.title,
          date: DateTime.now(),
          startedAt: DateTime.now(),
        ),
      );

      final result = await repository.deleteRoutine(seeded.id);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('진행 중'));
    });

    test('활성 루틴을 지우면 남은 루틴이 활성이 된다', () async {
      final seeded = await activeRoutine();
      final second = await importSimple();

      expect((await repository.deleteRoutine(seeded.id)).isOk, isTrue);
      expect((await activeRoutine()).id, second);
    });

    test('복제하면 이름에 복사본이 붙고 그래프는 같다', () async {
      final seeded = await activeRoutine();
      final result = await repository.duplicateRoutine(seeded.id);
      expect(
        result.valueOrNull,
        isNotNull,
        reason: result.failureOrNull?.message,
      );

      final original = await exportOf(seeded.id);
      final copy = await exportOf(result.valueOrNull!);

      expect(copy.name, '${seeded.name} 복사본');
      expect(copy.copyWith(name: seeded.name), original);
      expect((await activeRoutine()).id, seeded.id, reason: '복제는 활성을 바꾸지 않는다');
    });

    test('복제를 두 번 하면 이름이 겹치지 않는다', () async {
      final seeded = await activeRoutine();
      await repository.duplicateRoutine(seeded.id);
      final second = await repository.duplicateRoutine(seeded.id);

      final copy = await exportOf(second.valueOrNull!);
      expect(copy.name, '${seeded.name} 복사본 2');
    });
  });

  // ── file naming ─────────────────────────────────────────────────────────

  test('내보내기 파일명은 루틴 이름과 날짜로 만든다', () {
    const package = RoutinePackage(name: '상하체 2분할/50분');
    expect(
      codec.fileNameFor(package, DateTime(2026, 8, 11)),
      '상하체 2분할50분_20260811.json',
    );
  });
}
