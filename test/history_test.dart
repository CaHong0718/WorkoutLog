import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_app/core/constants/app_strings.dart';
import 'package:health_app/core/extensions/date_time_x.dart';
import 'package:health_app/data/database/app_database.dart';
import 'package:health_app/data/repository/history_repository_impl.dart';
import 'package:health_app/data/repository/routine_repository_impl.dart';
import 'package:health_app/data/repository/workout_repository_impl.dart';
import 'package:health_app/domain/entity/enums.dart';
import 'package:health_app/domain/entity/routine.dart';
import 'package:health_app/domain/entity/routine_day.dart';
import 'package:health_app/domain/entity/exercise_progress_point.dart';
import 'package:health_app/domain/entity/routine_item.dart';
import 'package:health_app/domain/entity/set_log.dart';
import 'package:health_app/domain/entity/workout_session.dart';
import 'package:health_app/domain/usecase/history_usecases.dart';
import 'package:health_app/domain/usecase/routine_usecases.dart';
import 'package:health_app/presentation/history/bloc/history_bloc.dart';
import 'package:health_app/presentation/history/bloc/history_intent.dart';
import 'package:health_app/presentation/history/bloc/history_state.dart';
import 'package:health_app/presentation/history/bloc/session_detail_bloc.dart';
import 'package:health_app/presentation/history/bloc/session_detail_intent.dart';
import 'package:health_app/presentation/history/bloc/session_detail_state.dart';
import 'package:health_app/presentation/history/bloc/stats_bloc.dart';
import 'package:health_app/presentation/history/bloc/stats_intent.dart';
import 'package:health_app/presentation/history/bloc/stats_state.dart';
import 'package:health_app/presentation/history/widget/exercise_trend_section.dart';
import 'package:health_app/presentation/history/widget/month_calendar.dart';
import 'package:health_app/presentation/history/widget/session_log_list.dart';

/// History and statistics against the real stack — bloc → use case →
/// repository → Drift — on an in-memory database seeded with the reference
/// routine.
void main() {
  late AppDatabase db;
  late RoutineRepositoryImpl routineRepo;
  late WorkoutRepositoryImpl workoutRepo;
  late HistoryRepositoryImpl historyRepo;
  late Routine routine;

  final today = DateTime.now().dateOnly;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    routineRepo = RoutineRepositoryImpl(db.routineDao, db);
    workoutRepo = WorkoutRepositoryImpl(db.workoutDao, db.routineDao, db);
    historyRepo = HistoryRepositoryImpl(db.historyDao);
    routine = (await routineRepo.getActiveRoutine()).valueOrNull!;
  });

  tearDown(() => db.close());

  RoutineDay dayOf(String code) =>
      routine.days.firstWhere((d) => d.code == code);

  HistoryBloc makeHistoryBloc() => HistoryBloc(
    GetWorkoutDates(historyRepo),
    GetSessions(historyRepo),
    GetSessionsOn(historyRepo),
    GetWeeklyVolume(historyRepo),
    GetTotalSessionCount(historyRepo),
  );

  StatsBloc makeStatsBloc() => StatsBloc(
    GetActiveRoutine(routineRepo),
    GetWeeklyVolume(historyRepo),
    GetSessions(historyRepo),
    GetExerciseProgress(historyRepo),
  );

  SessionDetailBloc makeDetailBloc(int sessionId) =>
      SessionDetailBloc(sessionId, GetSessionDetail(historyRepo));

  /// Starts a session and backdates it, so a whole history can be built
  /// without touching the clock.
  Future<WorkoutSession> startOn(String dayCode, DateTime date) async {
    final session = (await workoutRepo.startSession(dayOf(dayCode).id))
        .valueOrNull!;
    await (db.update(db.workoutSessions)
          ..where((t) => t.id.equals(session.id)))
        .write(
          WorkoutSessionsCompanion(
            date: Value(date.dateOnly),
            startedAt: Value(date),
          ),
        );
    return session;
  }

  Future<void> logSet(
    int sessionId,
    RoutineItem item, {
    required String blockLabel,
    required int itemOrder,
    required int setIndex,
    double? weight,
    int? reps,
    int? rir,
    int? restSeconds,
    bool isCompleted = true,
  }) async {
    await workoutRepo.logSet(
      SetLog(
        id: SetLog.unsavedId,
        sessionId: sessionId,
        routineItemId: item.id,
        exerciseId: item.exerciseId,
        exerciseName: item.exercise.name,
        bodyPart: item.bodyPart,
        blockLabel: blockLabel,
        itemOrder: itemOrder,
        setIndex: setIndex,
        weight: weight,
        reps: reps,
        rir: rir,
        restSeconds: restSeconds,
        isCompleted: isCompleted,
        completedAt: DateTime.now(),
      ),
    );
  }

  Future<HistoryState> loadHistory(HistoryBloc bloc) {
    bloc.add(const LoadHistory());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  Future<StatsState> loadStats(StatsBloc bloc) {
    bloc.add(const LoadStats());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  group('HistoryBloc — 달력', () {
    test('완료한 세션이 달력 마킹과 그날 목록에 나타난다', () async {
      final dayA = dayOf('A');
      final session = await startOn('A', today);
      final pullUp = dayA.blocks[0].items.single;

      for (var setIndex = 1; setIndex <= 4; setIndex++) {
        await logSet(
          session.id,
          pullUp,
          blockLabel: 'B1',
          itemOrder: 0,
          setIndex: setIndex,
          reps: 8,
        );
      }
      await workoutRepo.completeSession(session.id);

      final bloc = makeHistoryBloc();
      addTearDown(bloc.close);
      final state = await loadHistory(bloc);

      expect(state.workoutDates, contains(today));
      expect(state.dayBodyParts[today], BodyPart.back, reason: '메인 부위 색으로 마킹');
      expect(state.totalSessions, 1);
      expect(state.monthWorkoutCount, 1);

      bloc.add(SelectDate(today));
      final selected = await bloc.stream.firstWhere(
        (s) => s.selectedDate == today && !s.isDayLoading,
      );

      expect(selected.selectedSessions.single.dayCode, 'A');
      expect(selected.selectedSessions.single.completedSets, 4);
    });

    test('중단된 세션은 달력 마킹에 포함되지 않는다', () async {
      final dayA = dayOf('A');
      final session = await startOn('A', today);
      await logSet(
        session.id,
        dayA.blocks[0].items.single,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 1,
        reps: 6,
      );
      await workoutRepo.abortSession(session.id);

      final bloc = makeHistoryBloc();
      addTearDown(bloc.close);
      final state = await loadHistory(bloc);

      expect(state.workoutDates, isEmpty);
      expect(state.dayBodyParts, isEmpty);
      expect(state.totalSessions, 0);

      // The record itself is not hidden — the day list still shows it.
      bloc.add(SelectDate(today));
      final selected = await bloc.stream.firstWhere(
        (s) => s.selectedDate == today && !s.isDayLoading,
      );
      expect(selected.selectedSessions.single.status, SessionStatus.aborted);
    });

    test('연속 운동 주 수는 이번 주부터 거꾸로 세다 빈 주에서 멈춘다', () async {
      final dayA = dayOf('A');
      // Weeks 0, 1, 2 trained; week 3 skipped; week 4 trained again.
      for (final weeksAgo in [0, 1, 2, 4]) {
        final date = DateTime(
          today.year,
          today.month,
          today.day - 7 * weeksAgo,
        );
        final session = await startOn('A', date);
        await logSet(
          session.id,
          dayA.blocks[0].items.single,
          blockLabel: 'B1',
          itemOrder: 0,
          setIndex: 1,
          reps: 8,
        );
        await workoutRepo.completeSession(session.id);
      }

      final bloc = makeHistoryBloc();
      addTearDown(bloc.close);
      final state = await loadHistory(bloc);

      expect(state.streakWeeks, 3);
      expect(state.totalSessions, 4);
    });
  });

  group('SessionDetailBloc — 세션 상세', () {
    test('총 볼륨과 완료 세트 수가 맞고 블록별로 묶인다', () async {
      final dayB = dayOf('B');
      final incline = dayB.blocks[0].items.single;
      final dumbbell = dayB.blocks[1].items.single;
      final session = await startOn('B', today);

      await logSet(
        session.id,
        incline,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 1,
        weight: 60,
        reps: 10,
        rir: 2,
        restSeconds: 118,
      );
      await logSet(
        session.id,
        incline,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 2,
        weight: 62.5,
        reps: 8,
        rir: 1,
      );
      // Skipped: recorded, but must not count toward volume.
      await logSet(
        session.id,
        incline,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 3,
        isCompleted: false,
      );
      await logSet(
        session.id,
        dumbbell,
        blockLabel: 'B2',
        itemOrder: 1,
        setIndex: 1,
        weight: 22.5,
        reps: 12,
      );
      await workoutRepo.completeSession(session.id, memo: '상부 자극 좋았음');

      final bloc = makeDetailBloc(session.id);
      addTearDown(bloc.close);
      bloc.add(const LoadSessionDetail());
      final state = await bloc.stream.firstWhere((s) => !s.isLoading);

      final detail = state.session!;
      expect(detail.dayCode, 'B');
      expect(detail.completedSets, 3);
      expect(detail.totalVolume, 60 * 10 + 62.5 * 8 + 22.5 * 12);
      expect(detail.memo, '상부 자극 좋았음');

      expect(state.blocks.map((b) => b.label).toList(), ['B1', 'B2']);
      final first = state.blocks.first;
      expect(first.completedSets, 2);
      expect(first.volume, 60 * 10 + 62.5 * 8);

      final exercise = first.exercises.single;
      expect(exercise.name, incline.exercise.name);
      expect(exercise.logs.length, 3, reason: '건너뛴 세트도 목록에는 남는다');
      expect(exercise.logs.last.isCompleted, isFalse);
      expect(exercise.logs.first.summary, '60kg × 10');
      expect(exercise.logs.first.restSeconds, 118);
    });
  });

  group('StatsBloc — 주간 볼륨', () {
    test('부위별 완료 세트가 루틴 목표와 나란히 집계된다', () async {
      final dayA = dayOf('A');
      final pullUp = dayA.blocks[0].items.single;
      final legCurl = dayA.blocks[2].items[0];
      final rearDelt = dayA.blocks[2].items[1];
      final session = await startOn('A', today);

      for (var setIndex = 1; setIndex <= 3; setIndex++) {
        await logSet(
          session.id,
          pullUp,
          blockLabel: 'B1',
          itemOrder: 0,
          setIndex: setIndex,
          reps: 8,
        );
      }
      for (var setIndex = 1; setIndex <= 2; setIndex++) {
        await logSet(
          session.id,
          legCurl,
          blockLabel: 'B3',
          itemOrder: 1,
          setIndex: setIndex,
          weight: 35,
          reps: 12,
        );
      }
      await logSet(
        session.id,
        rearDelt,
        blockLabel: 'B3',
        itemOrder: 2,
        setIndex: 1,
        weight: 6,
        reps: 18,
      );
      // Skipped sets never reach the volume chart.
      await logSet(
        session.id,
        rearDelt,
        blockLabel: 'B3',
        itemOrder: 2,
        setIndex: 2,
        isCompleted: false,
      );
      await workoutRepo.completeSession(session.id);

      final bloc = makeStatsBloc();
      addTearDown(bloc.close);
      final state = await loadStats(bloc);

      expect(state.weeklyVolume[BodyPart.back], 3);
      expect(state.weeklyVolume[BodyPart.legs], 2);
      expect(state.weeklyVolume[BodyPart.shoulder], 1);
      expect(state.weeklyVolume[BodyPart.chest], isNull);
      expect(state.completedSets, 6);

      // The target comes from the routine itself (02-ROUTINE-SEED.md §6).
      expect(state.targetSets, 70);
      expect(state.targetVolume[BodyPart.shoulder], 19);
      expect(state.targetVolume[BodyPart.chest], 17);
      expect(state.targetVolume[BodyPart.back], 16);
      expect(state.targetVolume[BodyPart.legs], 12);
      expect(state.targetVolume[BodyPart.arms], 6);
      expect(state.isCurrentWeek, isTrue);
    });

    test('주를 뒤로 넘기면 그 주의 볼륨만 보인다', () async {
      final dayA = dayOf('A');
      final pullUp = dayA.blocks[0].items.single;
      final lastWeek = DateTime(today.year, today.month, today.day - 7);

      final session = await startOn('A', lastWeek);
      await logSet(
        session.id,
        pullUp,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 1,
        reps: 9,
      );
      await workoutRepo.completeSession(session.id);

      final bloc = makeStatsBloc();
      addTearDown(bloc.close);
      final current = await loadStats(bloc);
      expect(current.completedSets, 0);

      bloc.add(const ChangeWeek(-1));
      final previous = await bloc.stream.firstWhere((s) => !s.isWeekLoading);

      expect(previous.weekStart, lastWeek.startOfWeek);
      expect(previous.weeklyVolume[BodyPart.back], 1);
      expect(previous.isCurrentWeek, isFalse);
    });
  });

  group('StatsBloc — 종목 추이', () {
    test('추이는 날짜순으로 정렬되고 그날 최고 중량을 고른다', () async {
      final dayB = dayOf('B');
      final incline = dayB.blocks[0].items.single;
      final dates = [
        DateTime(today.year, today.month, today.day - 14),
        DateTime(today.year, today.month, today.day - 7),
        today,
      ];
      // Heaviest set is deliberately not the first one of the day.
      const weights = <List<double>>[
        [50, 55],
        [60, 57.5],
        [62.5, 65],
      ];

      for (var i = 0; i < dates.length; i++) {
        final session = await startOn('B', dates[i]);
        for (var s = 0; s < weights[i].length; s++) {
          await logSet(
            session.id,
            incline,
            blockLabel: 'B1',
            itemOrder: 0,
            setIndex: s + 1,
            weight: weights[i][s],
            reps: 8,
          );
        }
        await workoutRepo.completeSession(session.id);
      }

      final bloc = makeStatsBloc();
      addTearDown(bloc.close);
      final state = await loadStats(bloc);

      expect(state.trendExercises.single.name, incline.exercise.name);
      expect(state.selectedExerciseId, incline.exerciseId);
      expect(state.hasTrend, isTrue);

      expect(state.progress.map((p) => p.date).toList(), dates);
      expect(state.progress.map((p) => p.topWeight).toList(), [55, 60, 65]);
      expect(state.progress.first.totalVolume, (50 + 55) * 8);
      expect(
        state.progress.last.estimated1RM,
        closeTo(65 * (1 + 8 / 30), 0.001),
      );
    });

    test('무게 기록이 없으면 추이 후보가 비어 있다', () async {
      final dayA = dayOf('A');
      final session = await startOn('A', today);
      // Pull-ups without added weight carry no weight column.
      await logSet(
        session.id,
        dayA.blocks[0].items.single,
        blockLabel: 'B1',
        itemOrder: 0,
        setIndex: 1,
        reps: 10,
      );
      await workoutRepo.completeSession(session.id);

      final bloc = makeStatsBloc();
      addTearDown(bloc.close);
      final state = await loadStats(bloc);

      expect(state.trendExercises, isEmpty);
      expect(state.selectedExerciseId, isNull);
      expect(state.progress, isEmpty);
      expect(state.hasTrend, isFalse);
    });
  });

  group('위젯', () {
    Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    );

    testWidgets('달력이 운동한 날을 표시하고 탭한 날짜를 돌려준다', (tester) async {
      final marked = DateTime(2026, 8, 11);
      DateTime? tapped;

      await pump(
        tester,
        MonthCalendar(
          month: DateTime(2026, 8),
          markedDates: {marked},
          dayBodyParts: {marked: BodyPart.shoulder},
          selectedDate: null,
          onChangeMonth: (_) {},
          onSelectDate: (date) => tapped = date,
        ),
      );

      expect(find.text('2026년 8월'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);

      await tester.tap(find.text('11'));
      expect(tapped, marked);
    });

    testWidgets('추이 섹션은 최고 중량과 추정 1RM 두 계열을 그린다', (tester) async {
      final state = StatsState(
        weekStart: DateTime(2026, 8, 3),
        isLoading: false,
        hasLoaded: true,
        trendExercises: const [
          TrendExercise(id: 7, name: '인클라인 벤치프레스', bodyPart: BodyPart.chest),
        ],
        selectedExerciseId: 7,
        progress: [
          ExerciseProgressPoint(
            date: DateTime(2026, 8, 1),
            topWeight: 60,
            reps: 8,
            totalVolume: 960,
          ),
          ExerciseProgressPoint(
            date: DateTime(2026, 8, 8),
            topWeight: 65,
            reps: 8,
            totalVolume: 1040,
          ),
        ],
      );

      await pump(tester, ExerciseTrendSection(state: state, onSelect: (_) {}));

      expect(find.text('인클라인 벤치프레스'), findsOneWidget);
      expect(find.text(AppStrings.topWeight), findsOneWidget);
      expect(find.text(AppStrings.estimated1RM), findsOneWidget);

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.data.lineBarsData.length, 2);
      expect(chart.data.lineBarsData.first.spots.length, 2);
    });

    testWidgets('데이터가 1개 이하면 차트 대신 안내를 보여준다', (tester) async {
      final state = StatsState(
        weekStart: DateTime(2026, 8, 3),
        isLoading: false,
        hasLoaded: true,
        trendExercises: const [
          TrendExercise(id: 7, name: '딥스', bodyPart: BodyPart.chest),
        ],
        selectedExerciseId: 7,
        progress: [
          ExerciseProgressPoint(
            date: DateTime(2026, 8, 1),
            topWeight: 20,
            reps: 10,
            totalVolume: 200,
          ),
        ],
      );

      await pump(tester, ExerciseTrendSection(state: state, onSelect: (_) {}));

      expect(find.byType(LineChart), findsNothing);
      expect(find.text(AppStrings.trendNeedsMoreData), findsOneWidget);
    });

    testWidgets('세트 목록은 건너뛴 세트를 따로 표시한다', (tester) async {
      final at = DateTime(2026, 8, 11, 19);
      SetLog sample({required int setIndex, bool isCompleted = true}) => SetLog(
        id: setIndex,
        sessionId: 1,
        exerciseId: 3,
        exerciseName: '티바로우',
        bodyPart: BodyPart.back,
        blockLabel: 'B2',
        itemOrder: 1,
        setIndex: setIndex,
        weight: isCompleted ? 60 : null,
        reps: isCompleted ? 10 : null,
        rir: isCompleted ? 1 : null,
        restSeconds: isCompleted ? 90 : null,
        isCompleted: isCompleted,
        completedAt: at,
      );

      await pump(
        tester,
        SessionLogList(
          blocks: [
            LoggedBlock(
              label: 'B2',
              exercises: [
                LoggedExercise(
                  name: '티바로우',
                  bodyPart: BodyPart.back,
                  logs: [
                    sample(setIndex: 1),
                    sample(setIndex: 2, isCompleted: false),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('티바로우'), findsOneWidget);
      expect(find.text('60kg × 10'), findsOneWidget);
      expect(find.text('${AppStrings.rir} 1'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text(AppStrings.skippedSet), findsOneWidget);
    });
  });
}
