import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/theme/app_theme.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/domain/entity/exercise.dart';
import 'package:workout_log/domain/entity/routine_block.dart';
import 'package:workout_log/domain/entity/routine_item.dart';
import 'package:workout_log/presentation/routine_edit/widget/block_editor_card.dart';
import 'package:workout_log/presentation/routine_edit/widget/exercise_picker_sheet.dart';
import 'package:workout_log/presentation/routine_edit/widget/item_edit_sheet.dart';

/// Widget-level checks for the editing surfaces. Deliberately free of the
/// database: these only assert that the layouts build and hand back the right
/// values.
void main() {
  const pullUp = Exercise(id: 1, name: '풀업', bodyPart: BodyPart.back);
  const legCurl = Exercise(
    id: 2,
    name: '레그컬',
    bodyPart: BodyPart.legs,
    equipment: '머신',
  );
  const legPress = Exercise(id: 3, name: '레그프레스', bodyPart: BodyPart.legs);
  const library = [pullUp, legCurl, legPress];

  const item = RoutineItem(
    id: 10,
    blockId: 1,
    order: 0,
    exercise: pullUp,
    sets: 4,
    repMin: 8,
    repMax: 10,
  );

  Widget host(Widget child) =>
      MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));

  /// Renders a button that opens [open] so sheets run inside a real route.
  Widget opener(Future<void> Function(BuildContext context) open) => host(
    Builder(
      builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () => open(context),
          child: const Text('열기'),
        ),
      ),
    ),
  );

  testWidgets('블록 카드가 종목과 드래그 손잡이를 그린다', (tester) async {
    const block = RoutineBlock(
      id: 1,
      dayId: 1,
      order: 0,
      label: 'B1',
      name: '메인 — 오늘의 약점',
      restSeconds: 120,
      targetMinutes: 13,
      isCuttable: false,
      items: [
        item,
        RoutineItem(
          id: 11,
          blockId: 1,
          order: 1,
          exercise: legCurl,
          sets: 3,
        ),
      ],
    );
    var reordered = '';

    // A block card lives inside the day editor's ListView; the nested
    // reorderable list must survive that nesting.
    await tester.pumpWidget(
      host(
        ListView(
          children: [
            BlockEditorCard(
              block: block,
              alternativesOf: (_) => const [legPress],
              onEditBlock: () {},
              onDeleteBlock: () {},
              onAddItem: () {},
              onEditItem: (_) {},
              onDeleteItem: (_) {},
              onReorderItems: (oldIndex, newIndex) =>
                  reordered = '$oldIndex→$newIndex',
            ),
          ],
        ),
      ),
    );

    expect(find.text('B1'), findsOneWidget);
    expect(find.text('풀업'), findsOneWidget);
    expect(find.text('레그컬'), findsOneWidget);
    expect(find.text('4 × 8–10'), findsOneWidget);
    expect(find.text('13′ · 휴식 120s'), findsOneWidget);
    expect(find.text('컷 불가 — 그날의 메인'), findsOneWidget);
    expect(find.textContaining('대체 종목 · 레그프레스'), findsNWidgets(2));
    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    expect(reordered, isEmpty);
  });

  testWidgets('종목 선택 시트가 검색으로 좁히고 선택을 돌려준다', (tester) async {
    Exercise? picked;
    await tester.pumpWidget(
      opener(
        (context) async => picked = await ExercisePickerSheet.show(
          context,
          exercises: library,
          excludedIds: const {3},
        ),
      ),
    );

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('풀업'), findsOneWidget);
    expect(find.text('레그프레스'), findsNothing, reason: '이미 쓰는 종목은 숨긴다');

    await tester.enterText(find.byType(TextField), '레그');
    await tester.pumpAndSettle();
    expect(find.text('풀업'), findsNothing);

    await tester.tap(find.text('레그컬'));
    await tester.pumpAndSettle();

    expect(picked?.id, 2);
  });

  testWidgets('종목 편집 시트가 시간 기반 목표로 바꿔 저장한다', (tester) async {
    RoutineItem? saved;
    await tester.pumpWidget(
      opener(
        (context) async => saved = await ItemEditSheet.show(
          context,
          item: item,
          exercises: library,
          blockRestSeconds: 120,
        ),
      ),
    );

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(find.text('풀업'), findsOneWidget);
    expect(find.text('최소 반복'), findsOneWidget);

    await tester.tap(find.text('시간'));
    await tester.pumpAndSettle();
    expect(find.text('최소 반복'), findsNothing);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(saved!.repMode, RepMode.duration);
    expect(saved!.durationSeconds, 300);
    expect(saved!.repMin, isNull);
    expect(saved!.sets, 4);
  });
}
