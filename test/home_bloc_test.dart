import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/repository/history_repository_impl.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';
import 'package:workout_log/data/repository/workout_repository_impl.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/set_log.dart';
import 'package:workout_log/domain/usecase/history_usecases.dart';
import 'package:workout_log/domain/usecase/routine_usecases.dart';
import 'package:workout_log/domain/usecase/workout_usecases.dart';
import 'package:workout_log/presentation/home/bloc/home_bloc.dart';
import 'package:workout_log/presentation/home/bloc/home_effect.dart';
import 'package:workout_log/presentation/home/bloc/home_intent.dart';
import 'package:workout_log/presentation/home/bloc/home_state.dart';

/// Exercises the whole stack — bloc → use case → repository → Drift — against
/// an in-memory database, so the wiring is verified without a device.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl routineRepo;
  late WorkoutRepositoryImpl workoutRepo;
  late HistoryRepositoryImpl historyRepo;
  late HomeBloc bloc;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    routineRepo = RoutineRepositoryImpl(db.routineDao, db);
    workoutRepo = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    historyRepo = HistoryRepositoryImpl(db.historyDao);

    bloc = HomeBloc(
      GetActiveRoutine(routineRepo),
      WatchActiveRoutine(routineRepo),
      GetNextDay(routineRepo),
      GetInProgressSession(workoutRepo),
      GetWeeklyVolume(historyRepo),
      StartSession(workoutRepo),
      AbortSession(workoutRepo),
    );
  });

  tearDown(() async {
    await bloc.close();
    await db.close();
  });

  Future<HomeState> load() async {
    bloc.add(const LoadHome());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  test('LoadHome은 활성 루틴과 순번상 첫 DAY를 싣는다', () async {
    final state = await load();

    expect(state.failure, isNull);
    expect(state.routine?.name, '무분할 40분');
    expect(state.selectedDay?.code, 'A');
    expect(state.weeklyTargetSets, 70);
    expect(state.hasInProgress, isFalse);
  });

  test('SelectDay는 순번을 무시하고 지정한 DAY를 보여준다', () async {
    final loaded = await load();
    final dayC = loaded.routine!.days.firstWhere((d) => d.code == 'C');

    bloc.add(SelectDay(dayC.id));
    final state = await bloc.stream.firstWhere(
      (s) => s.selectedDay?.code == 'C',
    );

    expect(state.selectedDay!.totalSets, 19);
    expect(state.selectedDay!.primaryBodyPart, BodyPart.shoulder);
  });

  test('StartWorkout은 세션을 만들고 OpenSession 이펙트를 낸다', () async {
    await load();

    final effect = bloc.effects.first;
    bloc.add(const StartWorkout());

    final opened = await effect;
    expect(opened, isA<OpenSession>());

    final session = (await workoutRepo.getInProgressSession()).valueOrNull;
    expect(session, isNotNull);
    expect(session!.dayCode, 'A');
    expect(session.status, SessionStatus.inProgress);
  });

  test('StartWorkout 직후에도 이어서 하기 상태가 남는다', () async {
    await load();

    bloc.add(const StartWorkout());
    final state = await bloc.stream.firstWhere((s) => !s.isStarting);

    // Home is not rebuilt when the session screen pops, so the state must
    // already know a session is running — otherwise the banner disappears and
    // the workout has no entry point left.
    expect(state.hasInProgress, isTrue);
    expect(state.inProgressSession!.dayCode, 'A');
  });

  test('ResumeWorkout은 진행 중 세션을 그대로 다시 연다', () async {
    final loaded = await load();
    final started = (await workoutRepo.startSession(
      loaded.routine!.days.first.id,
    )).valueOrNull!;
    await load();

    final effect = bloc.effects.first;
    bloc.add(const ResumeWorkout());

    expect(await effect, OpenSession(started.id));
    expect(
      (await workoutRepo.getInProgressSession()).valueOrNull?.id,
      started.id,
      reason: '이어서 하기는 세션을 새로 만들지 않는다',
    );
  });

  test('진행 중 세션이 있으면 LoadHome이 이어서 하기 상태를 싣는다', () async {
    final loaded = await load();
    final dayA = loaded.routine!.days.first;
    await workoutRepo.startSession(dayA.id);

    final state = await load();

    expect(state.hasInProgress, isTrue);
    expect(state.inProgressSession!.dayCode, 'A');
  });

  test('DiscardInProgress는 세션을 중단 처리하고 배너를 없앤다', () async {
    final loaded = await load();
    await workoutRepo.startSession(loaded.routine!.days.first.id);
    await load();

    bloc.add(const DiscardInProgress());
    final state = await bloc.stream.firstWhere((s) => !s.hasInProgress);

    expect(state.hasInProgress, isFalse);
    expect((await workoutRepo.getInProgressSession()).valueOrNull, isNull);
  });

  test('완료한 세트가 이번 주 볼륨에 집계된다', () async {
    final loaded = await load();
    final dayA = loaded.routine!.days.first;

    final session = (await workoutRepo.startSession(dayA.id)).valueOrNull!;
    final pullUp = dayA.blocks.first.items.single;

    for (var setIndex = 1; setIndex <= 4; setIndex++) {
      await workoutRepo.logSet(
        SetLog(
          id: SetLog.unsavedId,
          sessionId: session.id,
          routineItemId: pullUp.id,
          exerciseId: pullUp.exerciseId,
          exerciseName: pullUp.exercise.name,
          bodyPart: pullUp.bodyPart,
          blockLabel: 'B1',
          itemOrder: 0,
          setIndex: setIndex,
          reps: 8,
          completedAt: DateTime.now(),
        ),
      );
    }
    await workoutRepo.completeSession(session.id);

    final state = await load();

    expect(state.weeklyVolume[BodyPart.back], 4);
    expect(state.weeklyCompletedSets, 4);
    // The rotation moved on: DAY A is done, DAY B is next.
    expect(state.selectedDay?.code, 'A', reason: '수동 선택은 새로고침 후에도 유지된다');
    expect((await routineRepo.getNextDay()).valueOrNull?.code, 'B');
  });

  test('루틴 편집이 과거 기록의 종목명을 바꾸지 않는다', () async {
    final loaded = await load();
    final dayA = loaded.routine!.days.first;
    final session = (await workoutRepo.startSession(dayA.id)).valueOrNull!;
    final pullUp = dayA.blocks.first.items.single;

    await workoutRepo.logSet(
      SetLog(
        id: SetLog.unsavedId,
        sessionId: session.id,
        routineItemId: pullUp.id,
        exerciseId: pullUp.exerciseId,
        exerciseName: pullUp.exercise.name,
        bodyPart: pullUp.bodyPart,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 1,
        reps: 10,
        completedAt: DateTime.now(),
      ),
    );

    // Remove the routine item the log came from.
    await routineRepo.deleteItem(pullUp.id);

    final detail = (await workoutRepo.getSession(session.id)).valueOrNull!;
    expect(detail.setLogs.single.exerciseName, '풀업');
    expect(detail.setLogs.single.bodyPart, BodyPart.back);
  });
}
