import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/entity/routine_day.dart';

/// Verifies that the seeded program reproduces the numbers stated in
/// `docs/02-ROUTINE-SEED.md` §6. If a seed edit breaks the weekly balance,
/// this test is what catches it.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoutineRepositoryImpl(db.routineDao, db);
  });

  tearDown(() => db.close());

  Future<Routine> loadRoutine() async {
    final result = await repository.getActiveRoutine();
    final routine = result.valueOrNull;
    expect(routine, isNotNull, reason: result.failureOrNull?.message);
    return routine!;
  }

  test('시드가 무분할 40분 루틴 A~D 4일을 만든다', () async {
    final routine = await loadRoutine();

    expect(routine.name, '무분할 40분');
    expect(routine.sessionMinutes, 40);
    expect(routine.dayCount, 4);
    expect(routine.days.map((d) => d.code).toList(), ['A', 'B', 'C', 'D']);
  });

  test('DAY별 총 세트 수가 설계값과 일치한다', () async {
    final routine = await loadRoutine();
    final byCode = {for (final d in routine.days) d.code: d};

    expect(byCode['A']!.totalSets, 16);
    expect(byCode['B']!.totalSets, 16);
    expect(byCode['C']!.totalSets, 19);
    expect(byCode['D']!.totalSets, 19);
  });

  test('주간 부위별 볼륨이 설계값과 일치한다 (합계 70세트)', () async {
    final routine = await loadRoutine();
    final volume = routine.weeklyVolumeByBodyPart;

    expect(volume[BodyPart.shoulder], 19);
    expect(volume[BodyPart.chest], 17);
    expect(volume[BodyPart.back], 16);
    expect(volume[BodyPart.legs], 12);
    expect(volume[BodyPart.arms], 6);
    expect(routine.weeklySets, 70);
  });

  test('하체가 매 세션 고정 슬롯으로 3세트씩 들어간다', () async {
    final routine = await loadRoutine();

    for (final day in routine.days) {
      expect(
        day.volumeByBodyPart[BodyPart.legs],
        3,
        reason: 'DAY ${day.code}에 하체 3세트가 없습니다',
      );
    }
  });

  test('각 DAY의 B1은 컷 대상이 아니다', () async {
    final routine = await loadRoutine();

    for (final day in routine.days) {
      final b1 = day.blocks.firstWhere((b) => b.label == 'B1');
      expect(b1.isCuttable, isFalse, reason: 'DAY ${day.code} B1');
      expect(b1.items.first.sets, 4);
    }
  });

  test('DAY C의 B1은 사이드 레터럴이며 프레스보다 앞에 온다', () async {
    final routine = await loadRoutine();
    final dayC = routine.days.firstWhere((d) => d.code == 'C');

    expect(dayC.blocks[0].items.first.exercise.name, '사이드 레터럴 라이즈');
    expect(dayC.blocks[1].items.first.exercise.name, '스미스머신 시티드 숄더프레스');
  });

  test('슈퍼세트 블록은 3라운드로 설정된다', () async {
    final routine = await loadRoutine();

    final supersets = routine.days
        .expand((d) => d.blocks)
        .where((b) => b.type == BlockType.superset);

    expect(supersets, isNotEmpty);
    for (final block in supersets) {
      expect(block.rounds, 3);
      expect(block.items.length, 2);
    }
  });

  test('복근 슬롯은 5분 시간 기반이며 볼륨에 포함되지 않는다', () async {
    final routine = await loadRoutine();

    for (final day in routine.days) {
      final abs = day.blocks.firstWhere((b) => b.label == '복근');
      final item = abs.items.single;
      expect(item.repMode, RepMode.duration);
      expect(item.durationSeconds, 300);
      expect(abs.totalSets, 0);
    }
  });

  test('대체 종목이 지정되어 있다', () async {
    final routine = await loadRoutine();
    final dayA = routine.days.firstWhere((d) => d.code == 'A');
    final tbar = dayA.blocks[1].items.single;

    expect(tbar.exercise.name, '티바로우');
    expect(tbar.alternativeExerciseIds, isNotEmpty);
  });

  test('기록이 없으면 다음 DAY는 A다', () async {
    final result = await repository.getNextDay();
    final day = result.valueOrNull;

    expect(day, isNotNull, reason: result.failureOrNull?.message);
    expect(day!.code, 'A');
  });

  test('DAY 진행은 순번을 따르고 마지막 D 다음은 A로 돌아온다', () async {
    final routine = await loadRoutine();

    Future<void> completeSession(RoutineDay day) async {
      final workoutDao = db.workoutDao;
      final id = await workoutDao.insertSession(
        WorkoutSessionsCompanion.insert(
          routineId: routine.id,
          dayId: Value(day.id),
          dayCode: day.code,
          dayTitle: day.title,
          date: DateTime.now(),
          startedAt: DateTime.now(),
        ),
      );
      await workoutDao.finishSession(
        id,
        status: 'completed',
        endedAt: DateTime.now(),
      );
    }

    final byCode = {for (final d in routine.days) d.code: d};

    await completeSession(byCode['A']!);
    expect((await repository.getNextDay()).valueOrNull?.code, 'B');

    await completeSession(byCode['B']!);
    expect((await repository.getNextDay()).valueOrNull?.code, 'C');

    await completeSession(byCode['D']!);
    expect((await repository.getNextDay()).valueOrNull?.code, 'A');
  });
}
