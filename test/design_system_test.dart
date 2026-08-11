import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/core/theme/app_metrics.dart';
import 'package:workout_log/core/theme/app_palette.dart';
import 'package:workout_log/core/theme/app_theme.dart';
import 'package:workout_log/domain/entity/enums.dart';
import 'package:workout_log/presentation/common/body_part_ui.dart';
import 'package:workout_log/presentation/common/common_widgets.dart';
import 'package:workout_log/presentation/common/volume_rail.dart';

void main() {
  Widget host(ThemeData theme, Widget child) =>
      MaterialApp(theme: theme, home: child);

  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    testWidgets('$name: tab bar fits its 49px height plus the top inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          theme,
          Scaffold(
            bottomNavigationBar: ColoredBox(
              color: theme.extension<AppPalette>()!.surface,
              child: Padding(
                padding: const EdgeInsets.only(top: AppLayout.tabTopInset),
                child: NavigationBar(
                  selectedIndex: 0,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.today), label: '오늘'),
                    NavigationDestination(
                      icon: Icon(Icons.insights),
                      label: '기록',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.list_alt),
                      label: '루틴',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // The inset has to land inside the bar, not as a gap above it.
      expect(
        tester.getSize(find.byType(NavigationBar)).height,
        AppLayout.tabBarHeight,
      );
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.byType(NavigationBar),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .height,
        AppLayout.tabBarHeight + AppLayout.tabTopInset,
      );
    });

    testWidgets('$name: shared surfaces render', (tester) async {
      await tester.pumpWidget(
        host(
          theme,
          Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Eyebrow('Today'),
                const SizedBox(height: 10),
                const SectionCard(
                  accent: Color(0xFF059669),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyPartChip(BodyPart.chest, trailing: '4'),
                      SizedBox(height: 12),
                      VolumeProgressRow(
                        bodyPart: BodyPart.shoulder,
                        done: 12,
                        target: 19,
                      ),
                      VolumeRail(
                        segments: [
                          RailSegment(
                            flex: 3,
                            color: Color(0xFF059669),
                            label: '하체 3',
                          ),
                          RailSegment(
                            flex: 2,
                            color: Color(0xFFE11D48),
                            label: '가슴 2',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('운동 시작')),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: () {}, child: const Text('DAY 변경')),
                const SizedBox(height: 10),
                const TextField(decoration: InputDecoration(hintText: '검색')),
                const SizedBox(height: 10),
                ChoiceTile(
                  icon: Icons.play_arrow,
                  title: '이어서 하기',
                  description: '진행 중인 세션으로 돌아갑니다',
                  emphasized: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: loading skeleton and empty state render', (
      tester,
    ) async {
      await tester.pumpWidget(host(theme, const Scaffold(body: LoadingView())));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        host(
          theme,
          const Scaffold(
            body: EmptyView(message: '루틴이 없습니다', icon: Icons.inbox_outlined),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
