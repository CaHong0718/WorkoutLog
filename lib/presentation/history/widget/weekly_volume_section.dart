import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/volume_rail.dart';
import '../bloc/stats_state.dart';

/// Completed sets per body part for one week, against the routine's own plan
/// (70 sets over a full A→B→C→D rotation).
class WeeklyVolumeSection extends StatelessWidget {
  const WeeklyVolumeSection({
    required this.state,
    required this.onChangeWeek,
    super.key,
  });

  final StatsState state;
  final void Function(int delta) onChangeWeek;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final parts = state.volumeParts;
    final done = state.completedSets;
    final target = state.targetSets;
    final ratio = target == 0 ? 0.0 : (done / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => onChangeWeek(-1),
                    icon: const Icon(Icons.chevron_left, size: 22),
                    color: p.ink2,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '${state.weekStart.formatShort} – '
                            '${state.weekEnd.formatShort}',
                            style: context.type.cardTitle,
                          ),
                          if (state.isCurrentWeek)
                            Text(
                              AppStrings.thisWeek,
                              style: context.type.label.copyWith(
                                color: p.accent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: state.isCurrentWeek
                        ? null
                        : () => onChangeWeek(1),
                    icon: const Icon(Icons.chevron_right, size: 22),
                    color: p.ink2,
                    disabledColor: p.line,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.weeklyTarget,
                      style: context.type.label,
                    ),
                  ),
                  Text('$done', style: context.type.metric.copyWith(fontSize: 30)),
                  Text(
                    ' / $target ${AppStrings.setUnit}',
                    style: context.type.caption.copyWith(color: p.ink3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(height: 10, color: p.surface3),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(height: 10, color: p.accentFill),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (parts.isEmpty)
                Text(AppStrings.noWeekVolume, style: context.type.caption)
              else
                Opacity(
                  opacity: state.isWeekLoading ? 0.4 : 1,
                  child: Column(
                    children: [
                      for (final part in parts)
                        VolumeProgressRow(
                          bodyPart: part,
                          done: state.weeklyVolume[part] ?? 0,
                          target: state.targetVolume[part] ?? 0,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Eyebrow(AppStrings.volumeShare),
        const SizedBox(height: 12),
        SectionCard(
          child: done == 0
              ? Text(AppStrings.noWeekVolume, style: context.type.caption)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VolumeRail(
                      segments: [
                        for (final part in parts)
                          if ((state.weeklyVolume[part] ?? 0) > 0)
                            RailSegment(
                              flex: state.weeklyVolume[part]!,
                              color: part.color(context),
                              label: '${part.label} ${state.weeklyVolume[part]}',
                            ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '완료한 세트만 집계합니다. 건너뛴 세트는 빠집니다.',
                      style: context.type.caption,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
