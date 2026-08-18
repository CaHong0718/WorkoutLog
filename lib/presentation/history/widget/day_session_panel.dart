import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/workout_session.dart';
import '../../common/common_widgets.dart';
import 'history_metrics.dart';

/// Sessions recorded on the day the user tapped in the calendar.
class DaySessionPanel extends StatelessWidget {
  const DaySessionPanel({
    required this.date,
    required this.sessions,
    required this.onOpen,
    this.isLoading = false,
    super.key,
  });

  final DateTime? date;
  final List<WorkoutSession> sessions;
  final bool isLoading;
  final void Function(WorkoutSession session) onOpen;

  @override
  Widget build(BuildContext context) {
    final selected = date;
    if (selected == null) {
      return SectionCard(
        child: Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 18,
              color: context.palette.ink3,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(AppStrings.pickDateHint, style: context.type.caption),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(selected.formatKo, style: context.type.cardTitle),
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (!isLoading && sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                AppStrings.noRecordThisDay,
                style: context.type.caption,
              ),
            )
          else
            for (final session in sessions)
              _SessionRow(session: session, onTap: () => onOpen(session)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.onTap});

  final WorkoutSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isCompleted = session.status == SessionStatus.completed;
    final detail = [
      session.duration.koreanShort,
      '${session.completedSets}${AppStrings.setUnit}',
      '${formatKg(session.totalVolume)}kg',
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.dayTitle,
                    style: context.type.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: context.type.caption),
                ],
              ),
            ),
            if (!isCompleted)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  session.status.label,
                  style: context.type.label.copyWith(
                    color: session.isInProgress ? p.accent : p.warn,
                  ),
                ),
              ),
            // A running session continues here rather than opening the
            // read-only record, so it gets the play affordance.
            Icon(
              session.isInProgress
                  ? Icons.play_circle_outline
                  : Icons.chevron_right,
              size: session.isInProgress ? 20 : 18,
              color: session.isInProgress ? p.accent : p.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
