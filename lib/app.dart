import 'dart:async';

import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/platform/routine_file_io.dart';
import 'core/platform/shared_routine_receiver.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/dismiss_keyboard.dart';

class HealthApp extends StatefulWidget {
  const HealthApp({super.key});

  @override
  State<HealthApp> createState() => _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  StreamSubscription<PickedRoutineFile>? _incoming;

  @override
  void initState() {
    super.initState();

    // A routine shared from another app opens the library with its import
    // preview already up. Started after the first frame so the router has a
    // navigator to push onto — a share can launch the app cold.
    final receiver = getIt<SharedRoutineReceiver>();
    _incoming = receiver.incoming.listen(_openImport);
    WidgetsBinding.instance.addPostFrameCallback((_) => receiver.start());
  }

  @override
  void dispose() {
    _incoming?.cancel();
    super.dispose();
  }

  void _openImport(PickedRoutineFile file) {
    appRouter.pushNamed(Routes.routineList, extra: file);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // Wraps every route, including dialogs and bottom sheets pushed above it.
      builder: (context, child) =>
          DismissKeyboard(child: child ?? const SizedBox.shrink()),
    );
  }
}
