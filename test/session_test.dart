import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/notification/rest_notifier.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/repository/exercise_repository_impl.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/data/repository/workout_repository_impl.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/routine.dart';
import 'package:workout_log/domain/entity/exercise.dart';
import 'package:workout_log/domain/entity/routine_block.dart';
import 'package:workout_log/domain/entity/routine_day.dart';
import 'package:workout_log/domain/entity/routine_item.dart';
import 'package:workout_log/domain/entity/session_plan.dart';
import 'package:workout_log/domain/usecase/exercise_usecases.dart';
import 'package:workout_log/domain/usecase/routine_usecases.dart';
import 'package:workout_log/domain/usecase/workout_usecases.dart';
import 'package:workout_log/presentation/session/bloc/session_bloc.dart';
import 'package:workout_log/presentation/session/bloc/session_intent.dart';
import 'package:workout_log/presentation/session/bloc/session_state.dart';

void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl routineRepo;
  late WorkoutRepositoryImpl workoutRepo;
  late ExerciseRepositoryImpl exerciseRepo;
  late Routine routine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineRepo = RoutineRepositoryImpl(db.routineDao, db);
    workoutRepo = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    exerciseRepo = ExerciseRepositoryImpl(db.exerciseDao);
    routine = (await routineRepo.getActiveRoutine()).valueOrNull!;
  });

  tearDown(() => db.close());

  RoutineDay dayOf(String code) =>
      routine.days.firstWhere((d) => d.code == code);

  /// A superset block, built by hand. The seed dropped supersets, but the
  /// block type still exists for routines the user writes, so the round
  /// interleaving stays covered here.
  RoutineDay supersetDay() {
    const legCurl = Exercise(id: 1, name: '레그컬', bodyPart: BodyPart.legs);
    const rearDelt = Exercise(
      id: 2,
      name: '벤트오버 레터럴 레이즈',
      bodyPart: BodyPart.shoulder,
    );

    return const RoutineDay(
      id: 1,
      routineId: 1,
      order: 0,
      code: 'X',
      title: '슈퍼세트 검증용',
      primaryBodyPart: BodyPart.legs,
      blocks: [
        RoutineBlock(
          id: 1,
          dayId: 1,
          order: 0,
          label: 'B3',
          restSeconds: 75,
          type: BlockType.superset,
          rounds: 3,
          items: [
            RoutineItem(
              id: 1,
              blockId: 1,
              order: 0,
              exercise: legCurl,
              sets: 3,
            ),
            RoutineItem(
              id: 2,
              blockId: 1,
              order: 1,
              exercise: rearDelt,
              sets: 3,
            ),
          ],
        ),
      ],
    );
  }

  SessionBloc makeBloc(int sessionId) => SessionBloc(
    sessionId,
    GetSession(workoutRepo),
    GetDayDetail(routineRepo),
    LogSet(workoutRepo),
    UpdateSet(workoutRepo),
    DeleteSet(workoutRepo),
    CompleteSession(workoutRepo),
    AbortSession(workoutRepo),
    GetLastLogsForExercise(workoutRepo),
    GetExercisesByIds(exerciseRepo),
    SuggestProgression(workoutRepo),
    // The real notifier: every platform call is guarded, so on the test host it
    // degrades to a no-op. That resilience is part of what we want covered.
    RestNotifier(),
  );

  group('SessionPlan', () {
    test('DAY A는 17개의 세트로 펼쳐진다', () {
      final plan = SessionPlan.fromDay(dayOf('A'));
      // B1 4 + B2 3 + B3 슈퍼세트 3라운드×2 + B4 (2+1) + 복근 1
      expect(plan.length, 17);
    });

    test('슈퍼세트는 라운드로 교대한다 (A1 B1 · A2 B2 · A3 B3)', () {
      final plan = SessionPlan.fromDay(supersetDay());

      expect(plan.length, 6);
      expect(plan.map((p) => '${p.item.exercise.name}/${p.setIndex}').toList(), [
        '레그컬/1',
        '벤트오버 레터럴 레이즈/1',
        '레그컬/2',
        '벤트오버 레터럴 레이즈/2',
        '레그컬/3',
        '벤트오버 레터럴 레이즈/3',
      ]);
    });

    test('슈퍼세트 휴식은 라운드 끝에서만 발생한다', () {
      final plan = SessionPlan.fromDay(supersetDay());

      expect(plan[0].restAfterSeconds, 0, reason: '라운드 내 첫 종목 뒤에는 쉬지 않는다');
      expect(plan[1].restAfterSeconds, 75);
      expect(plan[2].restAfterSeconds, 0);
      expect(plan[3].restAfterSeconds, 75);
    });

    test('시드 루틴에는 슈퍼세트가 없다', () {
      // 헬스장에서 기구 두 대를 동시에 잡아야 해서 뺐다. 엔진은 그대로 살아
      // 있으므로 사용자가 만든 루틴에서는 계속 쓸 수 있다.
      for (final day in routine.days) {
        for (final block in day.blocks) {
          expect(
            block.type,
            BlockType.straight,
            reason: 'DAY ${day.code} ${block.label}',
          );
        }
      }
    });

    test('일반 블록은 매 세트마다 휴식이 붙는다', () {
      final plan = SessionPlan.fromDay(dayOf('A'));
      final b1 = plan.where((p) => p.blockLabel == 'B1').toList();

      expect(b1.length, 4);
      expect(b1.every((p) => p.restAfterSeconds == 120), isTrue);
      expect(b1.every((p) => !p.isCuttable), isTrue);
    });

    test('마지막 세트 뒤에는 휴식이 없다', () {
      for (final day in routine.days) {
        final plan = SessionPlan.fromDay(day);
        expect(plan.last.restAfterSeconds, 0, reason: 'DAY ${day.code}');
      }
    });

    test('DAY C는 20개 세트로 펼쳐진다', () {
      final plan = SessionPlan.fromDay(dayOf('C'));
      // B1 4 + B2 3 + B3 6 + B4 6 + 복근 1
      expect(plan.length, 20);
    });

    test('resumeIndex는 기록이 없는 첫 세트를 가리킨다', () {
      final plan = SessionPlan.fromDay(dayOf('A'));
      expect(SessionPlan.resumeIndex(plan, const []), 0);
    });
  });

  group('RestState — 벽시계 기준 카운트다운', () {
    final start = DateTime(2026, 8, 11, 12);

    test('백그라운드에 오래 있다 돌아와도 남은 시간이 정확하다', () {
      final rest = RestState.start(120, from: start);
      expect(rest.remainingSeconds, 120);
      expect(rest.endsAt, start.add(const Duration(seconds: 120)));

      // 화면을 끈 채 90초 — 그동안 tick은 한 번도 돌지 못했다고 가정
      final resumed = rest.tick(start.add(const Duration(seconds: 90)));
      expect(resumed.remainingSeconds, 30);
      expect(resumed.isDone, isFalse);
    });

    test('휴식 시간을 넘겨서 복귀하면 0으로 끝나 있다', () {
      final rest = RestState.start(75, from: start);
      final late = rest.tick(start.add(const Duration(minutes: 5)));

      expect(late.remainingSeconds, 0);
      expect(late.isDone, isTrue);
      expect(late.progress, 1);
    });

    test('+15초는 종료 시각 자체를 미룬다', () {
      final now = start.add(const Duration(seconds: 10));
      final rest = RestState.start(60, from: start).tick(now);
      expect(rest.remainingSeconds, 50);

      final extended = rest.extend(const Duration(seconds: 15), now: now);
      expect(extended.totalSeconds, 75);
      expect(extended.remainingSeconds, 65);
      expect(extended.endsAt, start.add(const Duration(seconds: 75)));
    });
  });

  group('SessionBloc', () {
    test('세트를 완료하면 다음으로 넘어가고 휴식이 시작된다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);
      expect(loaded.currentSet?.item.exercise.name, '풀업');
      expect(loaded.isResting, isFalse);

      bloc.add(const CompleteCurrentSet(reps: 10, rir: 1));
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      expect(after.isResting, isTrue);
      expect(after.rest!.totalSeconds, 120);
      expect(after.completedSets, 1);
      expect(after.currentSet?.setIndex, 2);
    });

    test('B3는 한 종목을 끝내고 다음 종목으로 넘어간다', () async {
      final session = (await workoutRepo.startSession(dayOf('A').id))
          .valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      // Jump to the first set of B3 (4 + 3 = index 7).
      bloc.add(const JumpToSet(7));
      final atB3 = await bloc.stream.firstWhere((s) => s.currentIndex == 7);
      expect(atB3.currentSet?.blockLabel, 'B3');
      expect(atB3.currentSet?.item.exercise.name, '레그컬');

      bloc.add(const CompleteCurrentSet(weight: 30, reps: 12));
      final mid = await bloc.stream.firstWhere((s) => s.currentIndex == 8);

      // 슈퍼세트 시절에는 여기서 쉬지 않고 다른 기구로 넘어갔다. 이제는 같은
      // 기구에서 이어 하므로 매 세트마다 휴식이 붙는다.
      expect(mid.isResting, isTrue);
      expect(mid.rest!.totalSeconds, 60, reason: 'B3 보조 블록의 휴식 규격');
      expect(mid.currentSet?.item.exercise.name, '레그컬');
      expect(mid.currentSet?.setIndex, 2);

      bloc.add(const CompleteCurrentSet(weight: 30, reps: 12));
      bloc.add(const CompleteCurrentSet(weight: 30, reps: 12));
      final next = await bloc.stream.firstWhere((s) => s.currentIndex == 10);

      expect(
        next.currentSet?.item.exercise.name,
        '벤트오버 레터럴 레이즈',
        reason: '레그컬 3세트를 다 끝낸 뒤에야 다음 종목이 나온다',
      );
    });

    test('블록 컷은 남은 세트를 건너뛴다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);
      final b4Index = loaded.plan.indexWhere((p) => p.blockLabel == 'B4');

      bloc.add(JumpToSet(b4Index));
      await bloc.stream.firstWhere((s) => s.currentIndex == b4Index);

      final b4BlockIndex = loaded.plan[b4Index].blockIndex;
      bloc.add(SkipBlock(b4BlockIndex));
      final after = await bloc.stream.firstWhere(
        (s) => s.skippedBlocks.contains(b4BlockIndex),
      );

      expect(after.currentSet?.blockLabel, '복근');
      expect(after.completedSets, 0, reason: '컷된 세트는 기록되지 않는다');
    });

    test('건너뛴 세트는 미완료로 기록되어 볼륨에 잡히지 않는다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const SkipCurrentSet());
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      expect(after.completedSets, 0);
      expect(after.session!.setLogs.single.isCompleted, isFalse);
      expect(after.isResting, isFalse);
    });

    test('앱을 껐다 켜도 진행 위치가 복원된다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final first = makeBloc(session.id);

      first.add(const LoadSession());
      await first.stream.firstWhere((s) => !s.isLoading);
      first.add(const CompleteCurrentSet(reps: 9));
      first.add(const CompleteCurrentSet(reps: 8));
      await first.stream.firstWhere((s) => s.currentIndex == 2);
      await first.close();

      final resumed = makeBloc(session.id);
      addTearDown(resumed.close);
      resumed.add(const LoadSession());
      final state = await resumed.stream.firstWhere((s) => !s.isLoading);

      expect(state.currentIndex, 2);
      expect(state.completedSets, 2);
      expect(state.currentSet?.setIndex, 3);
    });

    test('세션 대체 종목은 기록에 남지만 루틴은 바뀌지 않는다', () async {
      final dayA = dayOf('A');
      final session = (await workoutRepo.startSession(dayA.id)).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);

      // B2 티바로우 → 시티드 케이블 로우
      final tbarIndex = loaded.plan.indexWhere((p) => p.blockLabel == 'B2');
      bloc.add(JumpToSet(tbarIndex));
      await bloc.stream.firstWhere((s) => s.currentIndex == tbarIndex);

      final planned = loaded.plan[tbarIndex];
      final substitute = loaded.alternatives[planned.item.id]!.single;
      expect(substitute.name, '시티드 케이블 로우');

      bloc.add(SubstituteExercise(planned.item.id, substitute));
      await bloc.stream.firstWhere(
        (s) => s.substitutions.containsKey(planned.item.id),
      );

      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      final after = await bloc.stream.firstWhere(
        (s) => s.currentIndex == tbarIndex + 1,
      );

      expect(after.session!.setLogs.single.exerciseName, '시티드 케이블 로우');

      final reloaded = (await routineRepo.getDayDetail(dayA.id)).valueOrNull!;
      final b2 = reloaded.blocks.firstWhere((b) => b.label == 'B2');
      expect(b2.items.single.exercise.name, '티바로우', reason: '루틴 원본은 그대로');
    });

    test('복근 슬롯은 시간 기반으로 기록된다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);
      final absIndex = loaded.plan.indexWhere((p) => p.blockLabel == '복근');

      bloc.add(JumpToSet(absIndex));
      final atAbs = await bloc.stream.firstWhere(
        (s) => s.currentIndex == absIndex,
      );
      expect(atAbs.currentSet!.isTimed, isTrue);

      bloc.add(const CompleteCurrentSet(durationSeconds: 300));
      final after = await bloc.stream.firstWhere((s) => s.isFinished);

      final log = after.session!.setLogs.single;
      expect(log.durationSeconds, 300);
      expect(log.bodyPart, BodyPart.abs);
      expect(after.isResting, isFalse);
    });

    test('무게 0으로 기록한 세트는 맨몸으로 읽힌다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 0, reps: 12));
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      final log = after.session!.setLogs.single;
      expect(log.isBodyweight, isTrue);
      expect(log.summary, '맨몸 × 12');
      expect(log.estimated1RM, isNull, reason: '실린 무게가 없으면 1RM 추정이 없다');
    });
  });

  group('SessionBloc — 기록한 세트 고치기', () {
    test('되돌아가 다시 완료해도 세트가 늘지 않고 값만 덮인다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      bloc.add(const CompleteCurrentSet(weight: 50, reps: 9));
      final twoDone = await bloc.stream.firstWhere((s) => s.currentIndex == 2);
      expect(twoDone.completedSets, 2);

      // 1세트 무게를 잘못 넣었다 — 그 자리로 돌아가 다시 기록한다.
      bloc.add(const JumpToSet(0));
      final back = await bloc.stream.firstWhere((s) => s.currentIndex == 0);
      expect(back.logFor(back.plan.first)?.weight, 50);

      bloc.add(const CompleteCurrentSet(weight: 55, reps: 10));
      final fixed = await bloc.stream.firstWhere(
        (s) => s.session!.setLogs.first.weight == 55,
      );

      expect(fixed.session!.setLogs.length, 2, reason: '행이 늘어나면 안 된다');
      expect(fixed.completedSets, 2);
      expect(fixed.session!.setLogs.first.reps, 10);
      expect(fixed.currentIndex, 2, reason: '고친 뒤에는 아직 기록이 없는 세트로 돌아온다');
      expect(fixed.isResting, isFalse, reason: '방금 한 세트가 아니니 휴식도 없다');
    });

    test('되돌아가 건너뛰기를 눌러도 같은 행이 미완료로 바뀐다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      bloc.add(const JumpToSet(0));
      await bloc.stream.firstWhere((s) => s.currentIndex == 0);

      bloc.add(const SkipCurrentSet());
      final after = await bloc.stream.firstWhere((s) => s.completedSets == 0);

      expect(after.session!.setLogs.length, 1);
      expect(after.session!.setLogs.single.isCompleted, isFalse);
    });

    test('EditSetLog는 기록된 세트의 무게와 반복을 고친다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 40, reps: 8, rir: 2));
      final logged = await bloc.stream.firstWhere((s) => s.currentIndex == 1);
      final original = logged.session!.setLogs.single;

      bloc.add(EditSetLog(original.copyWith(weight: 42.5, reps: 11, rir: 0)));
      final edited = await bloc.stream.firstWhere(
        (s) => s.session!.setLogs.single.reps == 11,
      );

      final log = edited.session!.setLogs.single;
      expect(log.id, original.id, reason: '같은 행을 고친다');
      expect(log.weight, 42.5);
      expect(log.rir, 0);
      expect(edited.completedSets, 1);
      expect(edited.currentIndex, 1, reason: '값만 고쳤을 뿐이니 진행 위치는 그대로다');
    });

    test('DeleteSetLog는 세트를 지우고 그 자리로 되돌린다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      final twoDone = await bloc.stream.firstWhere((s) => s.currentIndex == 2);
      final first = twoDone.session!.setLogs.first;

      bloc.add(DeleteSetLog(first.id));
      final after = await bloc.stream.firstWhere(
        (s) => s.session!.setLogs.length == 1,
      );

      expect(after.completedSets, 1);
      expect(after.currentIndex, 0, reason: '빈 자리가 다시 현재 세트가 된다');
      expect(after.session!.setLogs.single.setIndex, 2);
    });
  });

  group('SessionBloc — 같은 종목의 값 이어받기', () {
    test('직전 세트의 무게와 횟수를 다음 세트가 이어받는다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const CompleteCurrentSet(weight: 60, reps: 10, rir: 1));
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      final carried = after.carryOverFor(after.currentSet!);
      expect(carried?.weight, 60);
      expect(carried?.reps, 10);
    });

    test('종목이 바뀌면 앞 종목의 무게를 이어받지 않는다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      // B1 풀업 4세트를 끝내면 다음은 B2의 다른 종목이다.
      for (var i = 0; i < 4; i++) {
        bloc.add(const CompleteCurrentSet(weight: 60, reps: 10));
      }
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 4);

      expect(after.currentSet?.blockLabel, 'B2');
      expect(after.carryOverFor(after.currentSet!), isNull);
    });

    test('건너뛴 세트는 이어받을 값이 없다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const SkipCurrentSet());
      final after = await bloc.stream.firstWhere((s) => s.currentIndex == 1);

      expect(after.carryOverFor(after.currentSet!), isNull, reason: '기록이 없는 세트다');
    });

    test('뒤 세트에만 기록이 있으면 앞 세트로 끌려오지 않는다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      // 1·2세트를 건너뛴 채 3세트부터 기록한 뒤 1세트 자리로 돌아온다.
      bloc.add(const JumpToSet(2));
      await bloc.stream.firstWhere((s) => s.currentIndex == 2);
      bloc.add(const CompleteCurrentSet(weight: 70, reps: 6));
      await bloc.stream.firstWhere((s) => s.currentIndex == 3);

      bloc.add(const JumpToSet(0));
      final back = await bloc.stream.firstWhere((s) => s.currentIndex == 0);

      expect(back.carryOverFor(back.currentSet!), isNull);
    });

    test('세션 대체 종목은 원래 종목의 무게를 이어받지 않는다', () async {
      final session = (await workoutRepo.startSession(
        dayOf('A').id,
      )).valueOrNull!;
      final bloc = makeBloc(session.id);
      addTearDown(bloc.close);

      bloc.add(const LoadSession());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);

      final b2Index = loaded.plan.indexWhere((p) => p.blockLabel == 'B2');
      bloc.add(JumpToSet(b2Index));
      await bloc.stream.firstWhere((s) => s.currentIndex == b2Index);

      bloc.add(const CompleteCurrentSet(weight: 50, reps: 10));
      await bloc.stream.firstWhere((s) => s.currentIndex == b2Index + 1);

      final planned = loaded.plan[b2Index];
      final substitute = loaded.alternatives[planned.item.id]!.single;
      bloc.add(SubstituteExercise(planned.item.id, substitute));
      final after = await bloc.stream.firstWhere(
        (s) => s.substitutions.containsKey(planned.item.id),
      );

      expect(
        after.carryOverFor(after.currentSet!),
        isNull,
        reason: '기구가 바뀌었으니 앞 종목의 50kg를 가져오면 안 된다',
      );
    });
  });
}
