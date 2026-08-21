import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/common/app_shell.dart';
import '../../presentation/backup/page/backup_page.dart';
import '../../presentation/common/branch_pager.dart';
import '../platform/json_file_io.dart';
import '../../presentation/history/page/history_page.dart';
import '../../presentation/history/page/session_detail_page.dart';
import '../../presentation/home/page/home_page.dart';
import '../../presentation/routine_edit/page/day_edit_page.dart';
import '../../presentation/routine_edit/page/exercise_library_page.dart';
import '../../presentation/routine_edit/page/routine_list_page.dart';
import '../../presentation/routine_edit/page/routine_page.dart';
import '../../presentation/session/page/session_page.dart';

/// Route names used with `context.goNamed` / `pushNamed`.
abstract final class Routes {
  static const home = 'home';
  static const history = 'history';

  /// The routine tab — always shows the active routine.
  static const routine = 'routine';

  /// The library of every routine.
  static const routineList = 'routineList';

  /// One routine by id, active or not.
  static const routineDetail = 'routineDetail';

  /// Record backup and restore, reached from the 기록 tab.
  static const backup = 'backup';

  static const session = 'session';
  static const sessionDetail = 'sessionDetail';
  static const dayEdit = 'dayEdit';
  static const exerciseLibrary = 'exerciseLibrary';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Not `.indexedStack`: the branches live in a PageView so they can be
    // swiped between. `preload` builds all three up front — a swipe would
    // otherwise drag a blank page into view the first time it reaches a tab.
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      navigatorContainerBuilder: (context, navigationShell, children) =>
          BranchPager(navigationShell: navigationShell, children: children),
      branches: [
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/',
              name: Routes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/history',
              name: Routes.history,
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/routine',
              name: Routes.routine,
              builder: (context, state) => const RoutinePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/backup',
      name: Routes.backup,
      parentNavigatorKey: _rootNavigatorKey,
      // `extra` carries a backup shared from another app; the page turns it
      // straight into a restore preview.
      builder: (context, state) => BackupPage(
        pendingRestore: state.extra is PickedJsonFile
            ? state.extra! as PickedJsonFile
            : null,
      ),
    ),
    GoRoute(
      path: '/session/:sessionId',
      name: Routes.session,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          SessionPage(sessionId: int.parse(state.pathParameters['sessionId']!)),
    ),
    GoRoute(
      path: '/history/session/:sessionId',
      name: Routes.sessionDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SessionDetailPage(
        sessionId: int.parse(state.pathParameters['sessionId']!),
      ),
    ),
    GoRoute(
      path: '/routines',
      name: Routes.routineList,
      parentNavigatorKey: _rootNavigatorKey,
      // `extra` carries a file shared from another app; the page turns it
      // straight into an import preview.
      builder: (context, state) => RoutineListPage(
        pendingImport: state.extra is PickedJsonFile
            ? state.extra! as PickedJsonFile
            : null,
      ),
      routes: [
        GoRoute(
          path: ':routineId',
          name: Routes.routineDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => RoutinePage(
            routineId: int.parse(state.pathParameters['routineId']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/routine/day/:dayId',
      name: Routes.dayEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          DayEditPage(dayId: int.parse(state.pathParameters['dayId']!)),
    ),
    GoRoute(
      path: '/exercises',
      name: Routes.exerciseLibrary,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExerciseLibraryPage(),
    ),
  ],
);
