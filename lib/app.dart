import 'dart:async';

import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/platform/json_file_io.dart';
import 'core/platform/shared_file_receiver.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/repository/backup_exchange.dart';
import 'core/widgets/dismiss_keyboard.dart';

class HealthApp extends StatefulWidget {
  const HealthApp({super.key});

  @override
  State<HealthApp> createState() => _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  StreamSubscription<PickedJsonFile>? _incoming;

  @override
  void initState() {
    super.initState();

    // A file shared from another app opens the screen that can read it, with
    // its preview already up. Started after the first frame so the router has
    // a navigator to push onto — a share can launch the app cold.
    final receiver = getIt<SharedFileReceiver>();
    _incoming = receiver.incoming.listen(_openShared);
    WidgetsBinding.instance.addPostFrameCallback((_) => receiver.start());
  }

  @override
  void dispose() {
    _incoming?.cancel();
    super.dispose();
  }

  /// Routed on the document's `format` field. Anything else falls through to
  /// the routine importer, which produces a readable error — better than
  /// guessing and silently doing nothing.
  void _openShared(PickedJsonFile file) {
    final route = file.format == BackupExchange.formatId
        ? Routes.backup
        : Routes.routineList;
    appRouter.pushNamed(route, extra: file);
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
