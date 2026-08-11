import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_palette.dart';

/// Bottom-navigation scaffold hosting the three primary branches.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // The strip carries the bar's own colour, so the inset reads as space
      // inside the bar rather than a gap above it.
      bottomNavigationBar: ColoredBox(
        color: context.palette.surface,
        child: Padding(
          padding: const EdgeInsets.only(top: AppLayout.tabTopInset),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: AppStrings.navHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: AppStrings.navHistory,
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: AppStrings.navRoutine,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
