import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/duration_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/set_log.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/session_detail_state.dart';
import 'history_metrics.dart';

/// The session's sets, grouped exactly as they were performed:
/// `block → exercise → set`. Skipped sets stay visible but struck through.
class SessionLogList extends StatelessWidget {
  const SessionLogList({
    required this.blocks,
    required this.onEditLog,
    super.key,
  });

  final List<LoggedBlock> blocks;

  /// Opens the editor for one recorded set — a finished record is still a
  /// record of what happened, and typos happen.
  final void Function(SetLog log) onEditLog;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return SectionCard(
        child: Text(AppStrings.noSetLogs, style: context.type.caption),
      );
    }

    return Column(
      children: [
        for (final block in blocks) ...[
          _BlockCard(block: block, onEditLog: onEditLog),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block, required this.onEditLog});

  final LoggedBlock block;
  final void Function(SetLog log) onEditLog;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  block.label,
                  style: context.type.label.copyWith(color: p.ink2),
                ),
              ),
              const Spacer(),
              Text(
                '${block.completedSets}${AppStrings.setUnit}'
                '${block.volume > 0 ? ' · ${formatKg(block.volume)}kg' : ''}',
                style: context.type.caption,
              ),
            ],
          ),
          for (final exercise in block.exercises) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                BodyPartBar(exercise.bodyPart, height: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: context.type.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                BodyPartChip(exercise.bodyPart, dense: true),
              ],
            ),
            const SizedBox(height: 4),
            for (final log in exercise.logs)
              _SetRow(log: log, onTap: () => onEditLog(log)),
          ],
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.log, required this.onTap});

  final SetLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rest = log.restSeconds;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '${log.setIndex}',
                style: context.type.label.copyWith(color: p.ink3),
              ),
            ),
            Expanded(
              child: Text(
                log.isCompleted ? log.summary : AppStrings.skippedSet,
                style: log.isCompleted
                    ? context.type.numeric.copyWith(fontSize: 13.5)
                    : context.type.caption.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
              ),
            ),
            if (log.isCompleted && log.rir != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  '${AppStrings.rir} ${log.rir}',
                  style: context.type.label.copyWith(color: p.ink3),
                ),
              ),
            if (rest != null && rest > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: p.ink3),
                  const SizedBox(width: 3),
                  Text(
                    rest.seconds.mmss,
                    style: context.type.caption.copyWith(
                      fontFeatures: AppTypography.tabular,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
