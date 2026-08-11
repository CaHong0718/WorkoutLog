import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/common/app_shell.dart';
import '../../presentation/history/page/history_page.dart';
import '../../presentation/history/page/session_detail_page.dart';
import '../../presentation/home/page/home_page.dart';
import '../../presentation/routine_edit/page/day_edit_page.dart';
import '../../presentation/routine_edit/page/exercise_library_page.dart';
import '../../presentation/routine_edit/page/routine_page.dart';
import '../../presentation/session/page/session_page.dart';

/// Route names used with `context.goNamed` / `pushNamed`.
abstract final class Routes {
  static const home = 'home';
  static const history = 'history';
  static const routine = 'routine';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: Routes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: Routes.history,
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
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
      path: '/session/:sessionId',
      name: Routes.session,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SessionPage(
        sessionId: int.parse(state.pathParameters['sessionId']!),
      ),
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
