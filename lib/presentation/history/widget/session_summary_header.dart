import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/workout_session.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/volume_rail.dart';
import 'history_metrics.dart';

/// Headline of one recorded session: what was trained, for how long, how much.
class SessionSummaryHeader extends StatelessWidget {
  const SessionSummaryHeader({required this.session, super.key});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final volume = session.volumeByBodyPart;
    final parts = volume.keys.toList()
      ..sort((a, b) => volume[b]!.compareTo(volume[a]!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          accent: parts.isEmpty ? null : parts.first.color(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'DAY ${session.dayCode}',
                      style: context.type.label.copyWith(color: p.ink2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      session.date.formatKo,
                      style: context.type.caption,
                    ),
                  ),
                  if (session.status != SessionStatus.completed)
                    Text(
                      session.status.label,
                      style: context.type.label.copyWith(color: p.warn),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(session.dayTitle, style: context.type.title),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MetricTile(
                      label: AppStrings.workoutDuration,
                      value: session.duration.koreanShort,
                    ),
                  ),
                  const MetricDivider(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MetricTile(
                      label: AppStrings.completedSetCount,
                      value: '${session.completedSets}',
                      unit: AppStrings.setUnit,
                    ),
                  ),
                  const MetricDivider(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MetricTile(
                      label: AppStrings.totalVolume,
                      value: formatKg(session.totalVolume),
                      unit: 'kg',
                    ),
                  ),
                ],
              ),
              if (parts.isNotEmpty) ...[
                const SizedBox(height: 16),
                VolumeRail(
                  height: 22,
                  segments: [
                    for (final part in parts)
                      RailSegment(
                        flex: volume[part]!,
                        color: part.color(context),
                        label: '${part.label} ${volume[part]}',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (session.memo != null && session.memo!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.sessionMemo, style: context.type.label),
                const SizedBox(height: 6),
                Text(session.memo!, style: context.type.body),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
