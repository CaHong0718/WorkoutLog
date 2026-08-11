import 'package:flutter/material.dart';

import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/session_state.dart';

/// Elapsed clock against the day's time budget, plus set progress.
class SessionHeader extends StatelessWidget {
  const SessionHeader({required this.state, super.key});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final target = Duration(minutes: state.targetMinutes);
    final overtime = state.elapsed > target;
    final ratio = target.inSeconds == 0
        ? 0.0
        : (state.elapsed.inSeconds / target.inSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      color: p.plane,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                state.elapsed.clock,
                style: context.type.metric.copyWith(
                  color: overtime ? p.warn : p.ink,
                ),
              ),
              Text(
                ' / ${target.koreanShort}',
                style: context.type.caption.copyWith(
                  fontFeatures: AppTypography.tabular,
                ),
              ),
              const Spacer(),
              Text(
                '${state.currentIndex}',
                style: context.type.numeric.copyWith(fontSize: 16),
              ),
              Text(
                ' / ${state.plannedSets} 세트',
                style: context.type.caption.copyWith(
                  fontFeatures: AppTypography.tabular,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 5, color: p.surface3),
                FractionallySizedBox(
                  widthFactor: state.progress,
                  child: Container(height: 5, color: p.accentFill),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 5,
                    color: (overtime ? p.warn : p.ink3).withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
