import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: p.accentWash,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.accentFill.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(AppStrings.rest, style: context.type.eyebrow),
          const SizedBox(height: 14),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1 - rest.progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: p.surface3,
                    valueColor: AlwaysStoppedAnimation(p.accentFill),
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
          const SizedBox(height: 14),
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
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
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
