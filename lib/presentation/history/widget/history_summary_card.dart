import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/common_widgets.dart';
import 'history_metrics.dart';

/// All-time totals plus the running weekly streak.
class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({
    required this.totalSessions,
    required this.weekSets,
    required this.streakWeeks,
    required this.monthWorkouts,
    super.key,
  });

  final int totalSessions;
  final int weekSets;
  final int streakWeeks;
  final int monthWorkouts;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MetricTile(
                  label: AppStrings.totalSessionCount,
                  value: '$totalSessions',
                  unit: AppStrings.sessionUnit,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricTile(
                  label: AppStrings.weekSetCount,
                  value: '$weekSets',
                  unit: AppStrings.setUnit,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MetricTile(
                  label: AppStrings.streakWeeks,
                  value: '$streakWeeks',
                  unit: AppStrings.weekUnit,
                  color: streakWeeks > 0 ? p.accent : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.monthWorkoutCount} $monthWorkouts${AppStrings.sessionUnit}',
            style: context.type.caption,
          ),
        ],
      ),
    );
  }
}
