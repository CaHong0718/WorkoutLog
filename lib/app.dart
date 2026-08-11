import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/dismiss_keyboard.dart';

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

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
