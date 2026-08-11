import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_log/presentation/common/branch_pager.dart';
import 'package:workout_log/presentation/common/branch_reveal.dart';

/// The bottom-navigation shell in isolation: three stand-in branches instead of
/// the real pages, so this stays free of the database and asserts only the two
/// things the shell owns — that branches can be swiped between, and that a
/// branch is told when it comes back on screen.
void main() {
  late Map<String, int> reveals;
  late GoRouter router;

  const paths = ['/a', '/b', '/c'];

  Widget branchPage(String path) => Scaffold(
    body: OnBranchReveal(
      onReveal: () => reveals[path] = (reveals[path] ?? 0) + 1,
      child: Center(child: Text('page $path')),
    ),
  );

  setUp(() {
    reveals = {};
    router = GoRouter(
      initialLocation: paths.first,
      routes: [
        StatefulShellRoute(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: shell.goBranch,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.looks_one), label: 'A'),
                NavigationDestination(icon: Icon(Icons.looks_two), label: 'B'),
                NavigationDestination(icon: Icon(Icons.looks_3), label: 'C'),
              ],
            ),
          ),
          navigatorContainerBuilder: (context, shell, children) =>
              BranchPager(navigationShell: shell, children: children),
          branches: [
            for (final path in paths)
              StatefulShellBranch(
                preload: true,
                routes: [
                  GoRoute(path: path, builder: (_, _) => branchPage(path)),
                ],
              ),
          ],
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  /// A page is 800 wide in the test surface; 500 clears the halfway mark that
  /// decides whether the page settles forward or springs back.
  Future<void> swipe(WidgetTester tester, {required bool forward}) async {
    await tester.drag(find.byType(PageView), Offset(forward ? -500 : 500, 0));
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// Visits every tab once and resets the counters. A branch is built the first
  /// time it is shown and loads on its own then, so only revisits are reveals.
  Future<void> visitAll(WidgetTester tester) async {
    for (final label in ['B', 'C', 'A']) {
      await tapTab(tester, label);
    }
    reveals.clear();
  }

  testWidgets('첫 빌드에도 첫 방문에도 갱신 신호가 오지 않는다', (tester) async {
    await pumpShell(tester);
    expect(selectedTab(tester), 0);
    expect(reveals, isEmpty);

    await tapTab(tester, 'B');
    expect(selectedTab(tester), 1);
    expect(reveals, isEmpty, reason: '그 자리에서 만들어진 페이지는 이미 최신이다');
  });

  testWidgets('좌우로 밀면 탭이 넘어가고 넘어간 탭만 갱신된다', (tester) async {
    await pumpShell(tester);
    await visitAll(tester);

    await swipe(tester, forward: true);
    expect(selectedTab(tester), 1);
    expect(reveals, {'/b': 1});

    await swipe(tester, forward: true);
    expect(selectedTab(tester), 2);
    expect(reveals, {'/b': 1, '/c': 1});

    await swipe(tester, forward: false);
    expect(selectedTab(tester), 1);
    expect(reveals, {'/b': 2, '/c': 1});
  });

  testWidgets('탭을 눌러 오갈 때마다 그 탭이 갱신된다', (tester) async {
    await pumpShell(tester);
    await visitAll(tester);

    await tapTab(tester, 'B');
    expect(selectedTab(tester), 1);
    expect(reveals, {'/b': 1});

    await tapTab(tester, 'A');
    expect(selectedTab(tester), 0);
    expect(reveals, {'/a': 1, '/b': 1});

    await tapTab(tester, 'B');
    expect(reveals, {'/a': 1, '/b': 2}, reason: '돌아올 때마다 다시 읽어야 한다');
  });

  testWidgets('건너뛴 탭은 지나가기만 할 뿐 갱신되지 않는다', (tester) async {
    await pumpShell(tester);
    await visitAll(tester);

    await tapTab(tester, 'C');

    expect(selectedTab(tester), 2);
    expect(reveals, {'/c': 1}, reason: 'A→C 애니메이션이 B를 스쳐도 B는 갱신 대상이 아니다');
  });
}
