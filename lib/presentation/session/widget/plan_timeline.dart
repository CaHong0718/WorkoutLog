import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/set_log.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/session_state.dart';

/// Whole-session view grouped by block, so the athlete can see what is left
/// and cut from the back when time runs short.
class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    required this.state,
    required this.onSkipBlock,
    required this.onJump,
    required this.onEditLog,
    super.key,
  });

  final SessionState state;
  final void Function(int blockIndex) onSkipBlock;
  final void Function(int planIndex) onJump;

  /// A row that already has a record opens the editor instead of jumping —
  /// the numbers get fixed in place rather than logged a second time.
  final void Function(SetLog log) onEditLog;

  @override
  Widget build(BuildContext context) {
    final groups = <int, List<int>>{};
    for (var i = 0; i < state.plan.length; i++) {
      groups.putIfAbsent(state.plan[i].blockIndex, () => []).add(i);
    }

    return Column(
      children: [
        for (final entry in groups.entries) ...[
          _BlockGroup(
            state: state,
            blockIndex: entry.key,
            planIndexes: entry.value,
            onSkipBlock: onSkipBlock,
            onJump: onJump,
            onEditLog: onEditLog,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BlockGroup extends StatelessWidget {
  const _BlockGroup({
    required this.state,
    required this.blockIndex,
    required this.planIndexes,
    required this.onSkipBlock,
    required this.onJump,
    required this.onEditLog,
  });

  final SessionState state;
  final int blockIndex;
  final List<int> planIndexes;
  final void Function(int blockIndex) onSkipBlock;
  final void Function(int planIndex) onJump;
  final void Function(SetLog log) onEditLog;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final first = state.plan[planIndexes.first];
    final isSkipped = state.skippedBlocks.contains(blockIndex);
    final isCurrent = state.currentSet?.blockIndex == blockIndex;
    final canSkip =
        first.isCuttable &&
        !isSkipped &&
        planIndexes.any((i) => i >= state.currentIndex);

    return Opacity(
      opacity: isSkipped ? 0.45 : 1,
      child: SectionCard(
        padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
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
                    color: isCurrent ? p.accentWash : p.surface3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    first.blockLabel,
                    style: context.type.label.copyWith(
                      color: isCurrent ? p.accent : p.ink2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    first.blockName ?? '',
                    style: context.type.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (first.isSuperset)
                  Text(
                    'SS ×${first.rounds}',
                    style: context.type.label.copyWith(color: p.accent),
                  ),
                if (canSkip)
                  TextButton(
                    onPressed: () => onSkipBlock(blockIndex),
                    style: TextButton.styleFrom(
                      foregroundColor: p.ink3,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('블록 컷'),
                  )
                else if (!first.isCuttable)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 8),
                    child: Icon(Icons.lock_outline, size: 14, color: p.warn),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final index in planIndexes)
              _PlanRow(
                state: state,
                planIndex: index,
                onJump: () => onJump(index),
                onEditLog: onEditLog,
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.state,
    required this.planIndex,
    required this.onJump,
    required this.onEditLog,
  });

  final SessionState state;
  final int planIndex;
  final VoidCallback onJump;
  final void Function(SetLog log) onEditLog;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final planned = state.plan[planIndex];
    final exercise = state.exerciseFor(planned);
    final log = state.logFor(planned);
    final isCurrent = planIndex == state.currentIndex;
    final isDone = log != null && log.isCompleted;
    final isSkipped = log != null && !log.isCompleted;

    return InkWell(
      onTap: () => log == null ? onJump() : onEditLog(log),
      borderRadius: BorderRadius.circular(7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: isDone
                  ? Icon(Icons.check_circle, size: 15, color: p.accent)
                  : isSkipped
                  ? Icon(Icons.remove_circle_outline, size: 15, color: p.ink3)
                  : isCurrent
                  ? Icon(Icons.play_arrow_rounded, size: 17, color: p.accent)
                  : Icon(Icons.circle_outlined, size: 13, color: p.line),
            ),
            BodyPartBar(exercise.bodyPart, height: 13),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                exercise.name,
                style: context.type.caption.copyWith(
                  color: isCurrent ? p.ink : p.ink2,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  decoration: isSkipped ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              log != null && log.isCompleted
                  ? log.summary
                  : planned.isSuperset
                  ? '${planned.setIndex}R'
                  : '${planned.setIndex}세트',
              style: context.type.numeric.copyWith(
                fontSize: 12,
                color: isDone ? p.ink : p.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
