import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/session_state.dart';

/// Circular rest countdown shown between sets and superset rounds.
class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    required this.rest,
    required this.nextLabel,
    required this.onAddTime,
    required this.onSkip,
    super.key,
  });

  final RestState rest;

  /// What comes after the rest, e.g. `B3 · 2라운드/3 · 레그컬`.
  final String nextLabel;
  final VoidCallback onAddTime;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final remaining = Duration(seconds: rest.remainingSeconds.clamp(0, 9999));

    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: p.accentWash,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.rest,
            style: context.type.eyebrow.copyWith(color: p.accent),
          ),
          const SizedBox(height: 12),
          // The ring is sized to the readout inside it. The type scale tops out
          // at 24 for a timer, so a 150px ring would leave the number swimming.
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1 - rest.progress,
                    strokeWidth: AppLayout.progressHeight,
                    strokeCap: StrokeCap.round,
                    backgroundColor: p.surface2,
                    valueColor: AlwaysStoppedAnimation(p.accent),
                  ),
                ),
                Text(remaining.mmss, style: context.type.timer),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nextLabel,
            style: context.type.caption.copyWith(color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddTime,
                  child: const Text(AppStrings.addFifteen),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onSkip,
                  child: const Text(AppStrings.skipRest),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
