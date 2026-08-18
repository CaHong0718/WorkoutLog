import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/workout_session.dart';
import '../../common/common_widgets.dart';

/// What to do when 운동 시작 is pressed while a session is still open.
enum StartChoice {
  /// Open the running session instead of creating a new one.
  resume,

  /// Abort the running one and start the selected day fresh.
  startNew,
}

/// Asked before a new session replaces an unfinished one.
///
/// Starting closes the open session as aborted, which used to happen silently —
/// the running workout simply vanished from the home banner.
class InProgressSheet extends StatelessWidget {
  const InProgressSheet({required this.session, required this.day, super.key});

  final WorkoutSession session;

  /// The day the user was about to start.
  final RoutineDay day;

  static Future<StartChoice?> show(
    BuildContext context, {
    required WorkoutSession session,
    required RoutineDay day,
  }) => showModalBottomSheet<StartChoice>(
    context: context,
    builder: (_) => InProgressSheet(session: session, day: day),
  );

  @override
  Widget build(BuildContext context) {
    final done = session.completedSets;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sessionInProgress,
              style: context.type.sectionTitle,
            ),
            const SizedBox(height: 4),
            Text(
              'DAY ${session.dayCode} · ${session.dayTitle} · '
              '$done${AppStrings.setUnit} · ${session.duration.koreanShort} 경과',
              style: context.type.caption,
            ),
            const SizedBox(height: 16),
            ChoiceTile(
              icon: Icons.play_circle_outline,
              title: AppStrings.resumeSession,
              description: AppStrings.resumeSessionHint,
              emphasized: true,
              onTap: () => Navigator.of(context).pop(StartChoice.resume),
            ),
            const SizedBox(height: 10),
            ChoiceTile(
              icon: Icons.restart_alt,
              title: 'DAY ${day.code} ${AppStrings.startNewSession}',
              description: done == 0
                  ? '진행 중이던 운동은 중단으로 닫힙니다.'
                  : '진행 중이던 운동은 중단으로 닫힙니다. '
                        '이미 한 $done${AppStrings.setUnit}는 기록에 남습니다.',
              onTap: () => Navigator.of(context).pop(StartChoice.startNew),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
