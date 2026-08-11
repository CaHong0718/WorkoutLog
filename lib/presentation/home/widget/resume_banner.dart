import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/workout_session.dart';

/// Shown when a session was left unfinished — the app never silently drops it.
class ResumeBanner extends StatelessWidget {
  const ResumeBanner({
    required this.session,
    required this.onResume,
    required this.onDiscard,
    super.key,
  });

  final WorkoutSession session;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // The whole banner resumes: the button is the label for the tap target,
    // not the only way to hit it.
    return Material(
      color: p.accentWash,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onResume,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.accentFill.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, color: p.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.sessionInProgress,
                      style: context.type.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DAY ${session.dayCode} · ${session.dayTitle} · '
                      '${session.completedSets}${AppStrings.setUnit} · '
                      '${session.duration.koreanShort} 경과',
                      style: context.type.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onDiscard,
                style: TextButton.styleFrom(foregroundColor: p.ink3),
                child: const Text('중단'),
              ),
              FilledButton(
                onPressed: onResume,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text(AppStrings.resumeSession),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
