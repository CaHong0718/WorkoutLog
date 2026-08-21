import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/constants/app_strings.dart';
import 'package:workout_log/core/theme/app_theme.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/exercise.dart';
import 'package:workout_log/domain/entity/routine_item.dart';
import 'package:workout_log/domain/entity/session_plan.dart';
import 'package:workout_log/domain/entity/set_log.dart';
import 'package:workout_log/presentation/common/set_inputs.dart';
import 'package:workout_log/presentation/session/widget/current_set_card.dart';

/// What the weight and reps fields start out holding. Typing the same numbers
/// again every set was the single most common complaint about the session
/// screen, so the seeding order is pinned down here.
void main() {
  const benchPress = Exercise(id: 1, name: '벤치프레스', bodyPart: BodyPart.chest);

  const item = RoutineItem(
    id: 10,
    blockId: 1,
    order: 0,
    exercise: benchPress,
    sets: 4,
    repMin: 8,
    repMax: 10,
  );

  PlannedSet plannedSet(int setIndex) => PlannedSet(
    blockIndex: 0,
    blockLabel: 'B1',
    blockType: BlockType.straight,
    rounds: 1,
    item: item,
    itemOrder: 0,
    setIndex: setIndex,
    restAfterSeconds: 120,
    isCuttable: false,
  );

  SetLog log(int setIndex, {double? weight, int? reps}) => SetLog(
    id: setIndex,
    sessionId: 1,
    routineItemId: item.id,
    exerciseId: benchPress.id,
    exerciseName: benchPress.name,
    bodyPart: benchPress.bodyPart,
    blockLabel: 'B1',
    itemOrder: 0,
    setIndex: setIndex,
    weight: weight,
    reps: reps,
    completedAt: DateTime(2026, 8, 20),
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    required PlannedSet planned,
    List<SetLog> previousLogs = const [],
    SetLog? carryOver,
    SetLog? existingLog,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CurrentSetCard(
              planned: planned,
              exercise: benchPress,
              previousLogs: previousLogs,
              carryOver: carryOver,
              existingLog: existingLog,
              onComplete: (_) {},
              onSkip: () {},
              onSubstitute: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester, String label) => tester
      .widget<SetNumberRow>(
        find.byWidgetPredicate((w) => w is SetNumberRow && w.label == label),
      )
      .controller
      .text;

  testWidgets('직전 세트를 60kg로 했으면 다음 세트도 60kg로 시작한다', (tester) async {
    await pumpCard(
      tester,
      planned: plannedSet(2),
      carryOver: log(1, weight: 60, reps: 10),
      previousLogs: [log(2, weight: 50, reps: 8)],
    );

    expect(fieldText(tester, AppStrings.weight), '60');
    expect(fieldText(tester, AppStrings.reps), '10');
  });

  testWidgets('이번 세션 기록이 없으면 지난 세션의 같은 세트를 따라간다', (tester) async {
    await pumpCard(
      tester,
      planned: plannedSet(2),
      previousLogs: [log(2, weight: 52.5, reps: 9), log(1, weight: 50, reps: 8)],
    );

    expect(fieldText(tester, AppStrings.weight), '52.5');
    expect(fieldText(tester, AppStrings.reps), '9');
  });

  testWidgets('되돌아가 고치는 세트는 자기 기록을 보여준다', (tester) async {
    await pumpCard(
      tester,
      planned: plannedSet(1),
      existingLog: log(1, weight: 45, reps: 7),
      carryOver: log(1, weight: 60, reps: 10),
    );

    expect(fieldText(tester, AppStrings.weight), '45');
    expect(fieldText(tester, AppStrings.reps), '7');
    expect(find.text(AppStrings.relogBadge), findsOneWidget);
  });

  testWidgets('맨몸으로 한 직전 세트는 무게 칸을 비워 둔다', (tester) async {
    await pumpCard(
      tester,
      planned: plannedSet(2),
      carryOver: log(1, reps: 12),
      previousLogs: [log(2, weight: 20, reps: 10)],
    );

    expect(fieldText(tester, AppStrings.weight), '');
    expect(fieldText(tester, AppStrings.reps), '12');
  });

  testWidgets('참고할 기록이 아무것도 없으면 처방된 최소 반복만 채운다', (tester) async {
    await pumpCard(tester, planned: plannedSet(1));

    expect(fieldText(tester, AppStrings.weight), '');
    expect(fieldText(tester, AppStrings.reps), '8');
  });
}
