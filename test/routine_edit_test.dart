import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/error/failure.dart';
import 'package:health_app/data/database/app_database.dart';
import 'package:health_app/data/repository/exercise_repository_impl.dart';
import 'package:health_app/data/repository/routine_repository_impl.dart';
import 'package:health_app/data/repository/workout_repository_impl.dart';
import 'package:health_app/domain/entity/enums.dart';
import 'package:health_app/domain/entity/exercise.dart';
import 'package:health_app/domain/entity/routine_day.dart';
import 'package:health_app/domain/entity/session_plan.dart';
import 'package:health_app/domain/entity/set_log.dart';
import 'package:health_app/domain/usecase/exercise_usecases.dart';
import 'package:health_app/domain/usecase/routine_usecases.dart';
import 'package:health_app/presentation/routine_edit/bloc/day_edit_bloc.dart';
import 'package:health_app/presentation/routine_edit/bloc/day_edit_intent.dart';
import 'package:health_app/presentation/routine_edit/bloc/day_edit_state.dart';
import 'package:health_app/presentation/routine_edit/bloc/exercise_library_bloc.dart';
import 'package:health_app/presentation/routine_edit/bloc/exercise_library_effect.dart';
import 'package:health_app/presentation/routine_edit/bloc/exercise_library_intent.dart';
import 'package:health_app/presentation/routine_edit/bloc/routine_bloc.dart';
import 'package:health_app/presentation/routine_edit/bloc/routine_effect.dart';
import 'package:health_app/presentation/routine_edit/bloc/routine_intent.dart';

/// Routine editing over the whole stack — bloc → use case → repository →
/// Drift — against an in-memory database seeded with the reference program.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl routineRepo;
  late ExerciseRepositoryImpl exerciseRepo;
  late WorkoutRepositoryImpl workoutRepo;
  late List<RoutineDay> days;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineRepo = RoutineRepositoryImpl(db.routineDao, db);
    exerciseRepo = ExerciseRepositoryImpl(db.exerciseDao);
    workoutRepo = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    days = (await routineRepo.getActiveRoutine()).valueOrNull!.days;
  });

  tearDown(() => db.close());

  RoutineDay dayOf(String code) => days.firstWhere((d) => d.code == code);

  DayEditBloc makeDayBloc(int dayId) {
    final bloc = DayEditBloc(
      dayId,
      GetDayDetail(routineRepo),
      GetAllExercises(exerciseRepo),
      UpsertDay(routineRepo),
      UpsertBlock(routineRepo),
      DeleteBlock(routineRepo),
      ReorderBlocks(routineRepo),
      UpsertItem(routineRepo),
      DeleteItem(routineRepo),
      ReorderItems(routineRepo),
    );
    addTearDown(bloc.close);
    return bloc;
  }

  RoutineBloc makeRoutineBloc() {
    final bloc = RoutineBloc(
      WatchActiveRoutine(routineRepo),
      UpsertDay(routineRepo),
      DeleteDay(routineRepo),
      ReorderDays(routineRepo),
    );
    addTearDown(bloc.close);
    return bloc;
  }

  ExerciseLibraryBloc makeLibraryBloc() {
    final bloc = ExerciseLibraryBloc(
      WatchExercises(exerciseRepo),
      UpsertExercise(exerciseRepo),
      DeleteExercise(exerciseRepo),
    );
    addTearDown(bloc.close);
    return bloc;
  }

  Future<DayEditState> loadDay(DayEditBloc bloc) {
    bloc.add(const LoadDay());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  /// Resolves on the state emitted after a write completed — the optimistic
  /// state a drag emits first is skipped, so the database is settled.
  Future<DayEditState> afterWrite(DayEditBloc bloc) {
    var sawSaving = false;
    return bloc.stream.firstWhere((state) {
      if (state.isSaving) {
        sawSaving = true;
        return false;
      }
      return sawSaving;
    });
  }

  group('DayEditBloc — 종목', () {
    test('블록에 종목을 추가하면 DAY 세트 수가 늘어난다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      expect(loaded.day!.totalSets, 16);

      final b2 = loaded.blocks.firstWhere((b) => b.label == 'B2');
      final legPress = loaded.exercises.firstWhere((e) => e.name == '레그프레스');

      bloc.add(CreateItem(blockId: b2.id, exercise: legPress));
      final after = await afterWrite(bloc);

      final block = after.blocks.firstWhere((b) => b.id == b2.id);
      expect(block.items.length, 2);
      expect(block.items.last.exercise.name, '레그프레스');
      expect(block.items.last.sets, 3, reason: '일반 블록의 기본값은 3세트');
      expect(after.day!.totalSets, 19);

      final reloaded = (await routineRepo.getDayDetail(dayA.id)).valueOrNull!;
      expect(reloaded.totalSets, 19, reason: 'DB에 반영된다');
    });

    test('종목 순서 변경이 저장된다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      final b3 = loaded.blocks.firstWhere((b) => b.label == 'B3');
      expect(b3.items.map((i) => i.exercise.name).toList(), [
        '레그컬',
        '벤트오버 레터럴 레이즈',
      ]);

      bloc.add(MoveItem(blockId: b3.id, oldIndex: 0, newIndex: 1));
      await afterWrite(bloc);

      final reloaded = (await routineRepo.getDayDetail(dayA.id)).valueOrNull!;
      final saved = reloaded.blocks.firstWhere((b) => b.label == 'B3');
      expect(saved.items.map((i) => i.exercise.name).toList(), [
        '벤트오버 레터럴 레이즈',
        '레그컬',
      ]);
      expect(saved.items.map((i) => i.order).toList(), [0, 1]);
    });

    test('종목을 빼면 남은 종목의 순서가 다시 촘촘해진다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      final b4 = loaded.blocks.firstWhere((b) => b.label == 'B4');
      expect(b4.items.length, 2);

      bloc.add(RemoveItem(b4.items.first.id));
      final after = await afterWrite(bloc);

      final block = after.blocks.firstWhere((b) => b.id == b4.id);
      expect(block.items.single.exercise.name, '덤벨컬');
      expect(block.items.single.order, 0);
    });
  });

  group('DayEditBloc — 블록', () {
    test('블록 타입을 슈퍼세트로 바꾸면 SessionPlan이 라운드 교대로 펼쳐진다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      final b2 = loaded.blocks.firstWhere((b) => b.label == 'B2');
      final lateral = loaded.exercises.firstWhere(
        (e) => e.name == '사이드 레터럴 라이즈',
      );

      bloc.add(CreateItem(blockId: b2.id, exercise: lateral));
      final withTwo = await afterWrite(bloc);

      final straight = withTwo.blocks.firstWhere((b) => b.id == b2.id);
      expect(SessionPlan.fromDay(withTwo.day!).where((p) => p.blockLabel == 'B2').length, 6);

      bloc.add(
        SaveBlock(
          straight.copyWith(type: BlockType.superset, rounds: 4, restSeconds: 75),
        ),
      );
      final asSuperset = await afterWrite(bloc);

      final block = asSuperset.blocks.firstWhere((b) => b.id == b2.id);
      expect(block.isSuperset, isTrue);
      expect(block.rounds, 4);
      expect(
        block.items.map((i) => i.sets).toList(),
        [4, 4],
        reason: '슈퍼세트 슬롯의 세트 수는 라운드 수를 따른다',
      );

      final plan = SessionPlan.fromDay(asSuperset.day!)
          .where((p) => p.blockLabel == 'B2')
          .toList();
      expect(plan.length, 8);
      expect(plan.map((p) => '${p.item.exercise.name}/${p.setIndex}').toList(), [
        '티바로우/1',
        '사이드 레터럴 라이즈/1',
        '티바로우/2',
        '사이드 레터럴 라이즈/2',
        '티바로우/3',
        '사이드 레터럴 라이즈/3',
        '티바로우/4',
        '사이드 레터럴 라이즈/4',
      ]);
      expect(plan[0].restAfterSeconds, 0, reason: '라운드 중간에는 쉬지 않는다');
      expect(plan[1].restAfterSeconds, 75);
    });

    test('블록을 추가하면 라벨이 이어지고 순서 변경이 저장된다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      await loadDay(bloc);
      bloc.add(const CreateBlock());
      final added = await afterWrite(bloc);

      expect(added.blocks.length, 6);
      expect(added.blocks.last.label, 'B5');

      bloc.add(const MoveBlock(oldIndex: 5, newIndex: 0));
      await afterWrite(bloc);

      final reloaded = (await routineRepo.getDayDetail(dayA.id)).valueOrNull!;
      expect(reloaded.blocks.first.label, 'B5');
      expect(reloaded.blocks.map((b) => b.order).toList(), [0, 1, 2, 3, 4, 5]);
    });

    test('블록을 삭제하면 안의 종목도 함께 사라진다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      final b3 = loaded.blocks.firstWhere((b) => b.label == 'B3');

      bloc.add(RemoveBlock(b3.id));
      final after = await afterWrite(bloc);

      expect(after.blocks.map((b) => b.label).contains('B3'), isFalse);
      expect(after.day!.totalSets, 10, reason: '16 - 슈퍼세트 6세트');
    });

    test('DAY 메타 편집이 저장된다', () async {
      final dayA = dayOf('A');
      final bloc = makeDayBloc(dayA.id);

      final loaded = await loadDay(bloc);
      bloc.add(
        SaveDayMeta(
          loaded.day!.copyWith(
            title: '등 + 이두 (수정)',
            subtitle: null,
            clearSubtitle: true,
            primaryBodyPart: BodyPart.arms,
          ),
        ),
      );
      final after = await afterWrite(bloc);

      expect(after.day!.title, '등 + 이두 (수정)');
      expect(after.day!.subtitle, isNull);
      expect(after.day!.primaryBodyPart, BodyPart.arms);
      expect(after.day!.order, 0, reason: '순번은 편집으로 바뀌지 않는다');
    });
  });

  group('과거 기록 보존', () {
    test('루틴에서 종목을 삭제해도 SetLog 스냅샷은 남는다', () async {
      final dayA = dayOf('A');
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
          reps: 9,
          completedAt: DateTime.now(),
        ),
      );

      final bloc = makeDayBloc(dayA.id);
      await loadDay(bloc);
      bloc.add(RemoveItem(pullUp.id));
      final after = await afterWrite(bloc);

      expect(after.blocks.first.items, isEmpty);

      final detail = (await workoutRepo.getSession(session.id)).valueOrNull!;
      expect(detail.setLogs.single.exerciseName, '풀업');
      expect(detail.setLogs.single.bodyPart, BodyPart.back);
      expect(detail.setLogs.single.blockLabel, 'B1');
      expect(detail.setLogs.single.reps, 9);
    });
  });

  group('RoutineBloc — DAY 목록', () {
    test('활성 루틴과 주간 볼륨을 싣는다', () async {
      final bloc = makeRoutineBloc();
      bloc.add(const LoadRoutine());
      final state = await bloc.stream.firstWhere((s) => !s.isLoading);

      expect(state.routine!.name, '무분할 40분');
      expect(state.days.map((d) => d.code).toList(), ['A', 'B', 'C', 'D']);
      expect(state.weeklySets, 70);
      expect(state.weeklyVolume[BodyPart.shoulder], 19);
    });

    test('DAY를 추가하면 편집 화면을 열고 목록 끝에 붙는다', () async {
      final bloc = makeRoutineBloc();
      bloc.add(const LoadRoutine());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      final effect = bloc.effects.first;
      bloc.add(
        const CreateDay(
          RoutineDay(
            id: RoutineDay.unsavedId,
            routineId: 0,
            order: 0,
            code: 'E',
            title: '가슴 보충',
            primaryBodyPart: BodyPart.chest,
          ),
        ),
      );

      final opened = await effect;
      expect(opened, isA<OpenDayEditor>());

      final state = await bloc.stream.firstWhere((s) => s.days.length == 5);
      expect(state.days.last.code, 'E');
      expect(state.days.last.order, 4);
    });

    test('DAY 순서를 바꾸면 순번이 다시 매겨진다', () async {
      final bloc = makeRoutineBloc();
      bloc.add(const LoadRoutine());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(const MoveDay(oldIndex: 0, newIndex: 2));
      final state = await bloc.stream.firstWhere(
        (s) => s.days.first.code == 'B' && s.days.first.order == 0,
      );

      expect(state.days.map((d) => d.code).toList(), ['B', 'C', 'A', 'D']);
      expect(state.days.map((d) => d.order).toList(), [0, 1, 2, 3]);
    });

    test('DAY를 삭제하면 남은 DAY의 순번이 촘촘해진다', () async {
      final bloc = makeRoutineBloc();
      bloc.add(const LoadRoutine());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(RemoveDay(dayOf('B').id));
      final state = await bloc.stream.firstWhere(
        (s) => s.days.length == 3 && s.days.every((d) => d.order < 3),
      );

      expect(state.days.map((d) => d.code).toList(), ['A', 'C', 'D']);
      expect(state.days.map((d) => d.order).toList(), [0, 1, 2]);
    });
  });

  group('ExerciseLibraryBloc', () {
    test('부위 필터와 검색이 목록을 좁힌다', () async {
      final bloc = makeLibraryBloc();
      bloc.add(const LoadLibrary());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);
      expect(loaded.visible.length, loaded.exercises.length);

      bloc.add(const FilterLibrary(BodyPart.legs));
      final filtered = await bloc.stream.firstWhere(
        (s) => s.bodyPart == BodyPart.legs,
      );
      expect(
        filtered.visible.every((e) => e.bodyPart == BodyPart.legs),
        isTrue,
      );

      bloc.add(const SearchLibrary('레그컬'));
      final searched = await bloc.stream.firstWhere((s) => s.query.isNotEmpty);
      expect(searched.visible.single.name, '레그컬');

      bloc.add(const FilterLibrary(null));
      final cleared = await bloc.stream.firstWhere((s) => s.bodyPart == null);
      expect(cleared.visible.single.name, '레그컬', reason: '검색어는 유지된다');
    });

    test('커스텀 종목을 추가하면 목록에 나타난다', () async {
      final bloc = makeLibraryBloc();
      bloc.add(const LoadLibrary());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(
        const SaveExercise(
          Exercise(
            id: Exercise.unsavedId,
            name: '케이블 크런치',
            bodyPart: BodyPart.abs,
            equipment: '케이블',
          ),
        ),
      );
      final state = await bloc.stream.firstWhere(
        (s) => s.exercises.any((e) => e.name == '케이블 크런치'),
      );

      final created = state.exercises.firstWhere((e) => e.name == '케이블 크런치');
      expect(created.isCustom, isTrue, reason: '직접 만든 종목으로 표시된다');
      expect(created.bodyPart, BodyPart.abs);
    });

    test('사용 중인 종목 삭제는 ValidationFailure를 반환한다', () async {
      final bloc = makeLibraryBloc();
      bloc.add(const LoadLibrary());
      final loaded = await bloc.stream.firstWhere((s) => !s.isLoading);
      final pullUp = loaded.exercises.firstWhere((e) => e.name == '풀업');

      final effect = bloc.effects.first;
      bloc.add(RemoveExercise(pullUp.id));
      final message = await effect;

      expect(message, isA<ShowLibraryMessage>());
      expect(
        (message as ShowLibraryMessage).message,
        '루틴에서 사용 중인 종목은 삭제할 수 없습니다.',
      );

      final result = await exerciseRepo.delete(pullUp.id);
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(
        (await exerciseRepo.getAll()).valueOrNull!.any((e) => e.id == pullUp.id),
        isTrue,
        reason: '종목은 그대로 남는다',
      );
    });

    test('루틴에서 쓰지 않는 종목은 삭제된다', () async {
      final bloc = makeLibraryBloc();
      bloc.add(const LoadLibrary());
      await bloc.stream.firstWhere((s) => !s.isLoading);

      bloc.add(
        const SaveExercise(
          Exercise(
            id: Exercise.unsavedId,
            name: '행잉 레그레이즈',
            bodyPart: BodyPart.abs,
          ),
        ),
      );
      final added = await bloc.stream.firstWhere(
        (s) => s.exercises.any((e) => e.name == '행잉 레그레이즈'),
      );
      final created = added.exercises.firstWhere((e) => e.name == '행잉 레그레이즈');

      bloc.add(RemoveExercise(created.id));
      final state = await bloc.stream.firstWhere(
        (s) => s.exercises.every((e) => e.name != '행잉 레그레이즈'),
      );

      expect(state.exercises.any((e) => e.id == created.id), isFalse);
    });
  });

}
