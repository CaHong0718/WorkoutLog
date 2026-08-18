import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/session_plan.dart';
import '../../../domain/entity/set_log.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/set_inputs.dart';

class CompletedSetValues {
  const CompletedSetValues({
    this.weight,
    this.reps,
    this.rir,
    this.durationSeconds,
  });

  final double? weight;
  final int? reps;
  final int? rir;
  final int? durationSeconds;
}

/// The set the athlete is on right now: prescription, coaching note, last
/// session's numbers, and the inputs to log it.
class CurrentSetCard extends StatefulWidget {
  const CurrentSetCard({
    required this.planned,
    required this.exercise,
    required this.previousLogs,
    required this.onComplete,
    required this.onSkip,
    required this.onSubstitute,
    this.existingLog,
    super.key,
  });

  final PlannedSet planned;
  final Exercise exercise;

  /// Logs of the same exercise from previous sessions, newest first.
  final List<SetLog> previousLogs;

  /// This set's own log when it was already performed — the athlete jumped
  /// back to fix it. Saving overwrites that row instead of adding a new one.
  final SetLog? existingLog;

  final void Function(CompletedSetValues values) onComplete;
  final VoidCallback onSkip;
  final VoidCallback onSubstitute;

  @override
  State<CurrentSetCard> createState() => _CurrentSetCardState();
}

class _CurrentSetCardState extends State<CurrentSetCard> {
  late final TextEditingController _weight = TextEditingController();
  late final TextEditingController _reps = TextEditingController();
  int? _rir;

  bool get _isRelog => widget.existingLog != null;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void didUpdateWidget(covariant CurrentSetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.planned.item.id != widget.planned.item.id ||
        oldWidget.planned.setIndex != widget.planned.setIndex ||
        oldWidget.exercise.id != widget.exercise.id ||
        oldWidget.existingLog?.id != widget.existingLog?.id;
    if (changed) _prefill();
  }

  /// Seeds the inputs from this set's own log when there is one, otherwise
  /// from the matching set of the previous session so the common case is a
  /// single tap.
  void _prefill() {
    final match =
        widget.existingLog ??
        widget.previousLogs
            .where((l) => l.setIndex == widget.planned.setIndex)
            .firstOrNull ??
        widget.previousLogs.firstOrNull;

    _weight.text = (match == null || match.isBodyweight)
        ? ''
        : trimWeight(match.weight!);
    _reps.text = match?.reps?.toString() ?? _defaultReps();
    _rir = widget.existingLog?.rir ?? widget.planned.item.targetRir;
    setState(() {});
  }

  String _defaultReps() {
    final item = widget.planned.item;
    return item.repMin?.toString() ?? '';
  }

  void _bumpWeight(double delta) {
    final current = double.tryParse(_weight.text) ?? 0;
    final next = (current + delta).clamp(0.0, 999.0);
    _weight.text = trimWeight(next);
  }

  void _bumpReps(int delta) {
    final current = int.tryParse(_reps.text) ?? 0;
    final next = (current + delta).clamp(0, 999);
    _reps.text = '$next';
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    if (widget.planned.isTimed) {
      widget.onComplete(
        CompletedSetValues(
          durationSeconds: widget.planned.item.durationSeconds,
        ),
      );
      return;
    }
    widget.onComplete(
      CompletedSetValues(
        weight: isBodyweightInput(_weight.text)
            ? null
            : double.tryParse(_weight.text),
        reps: int.tryParse(_reps.text),
        rir: _rir,
      ),
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final planned = widget.planned;
    final item = planned.item;
    final color = widget.exercise.bodyPart.color(context);

    return SectionCard(
      accent: color,
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                planned.positionLabel,
                style: context.type.label.copyWith(color: color),
              ),
              if (_isRelog) ...[
                const SizedBox(width: 8),
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
                    AppStrings.relogBadge,
                    style: context.type.label.copyWith(color: p.ink2),
                  ),
                ),
              ],
              const Spacer(),
              if (item.alternativeExerciseIds.isNotEmpty)
                TextButton.icon(
                  onPressed: widget.onSubstitute,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('대체'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.exercise.name, style: context.type.title),
          const SizedBox(height: 6),
          Row(
            children: [
              BodyPartChip(
                widget.exercise.bodyPart,
                trailing: widget.exercise.subTarget,
              ),
              const SizedBox(width: 8),
              Text(item.prescription, style: context.type.numeric),
              if (item.targetRir != null) ...[
                const SizedBox(width: 8),
                Text('RIR ${item.targetRir}', style: context.type.label),
              ],
            ],
          ),
          if (item.note != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(item.note!, style: context.type.caption),
            ),
          ],
          if (widget.previousLogs.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PreviousLogs(logs: widget.previousLogs),
          ],
          const SizedBox(height: 16),
          if (planned.isTimed)
            _TimedPrompt(seconds: item.durationSeconds ?? 300)
          else ...[
            SetNumberRow(
              label: AppStrings.weight,
              suffix: 'kg',
              controller: _weight,
              onDecrement: () => _bumpWeight(-kWeightStep),
              onIncrement: () => _bumpWeight(kWeightStep),
              decimal: true,
              zeroSuffix: AppStrings.bodyweight,
            ),
            const SizedBox(height: 10),
            SetNumberRow(
              label: AppStrings.reps,
              suffix: '회',
              controller: _reps,
              onDecrement: () => _bumpReps(-1),
              onIncrement: () => _bumpReps(1),
            ),
            const SizedBox(height: 12),
            RirSelector(
              value: _rir,
              onChanged: (value) => setState(() => _rir = value),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(
                    _isRelog ? AppStrings.saveSetEdit : _completeLabel(planned),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onSkip,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text(AppStrings.skip),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _completeLabel(PlannedSet planned) => planned.isTimed ? '완료' : '세트 완료';
}

class _PreviousLogs extends StatelessWidget {
  const _PreviousLogs({required this.logs});

  final List<SetLog> logs;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shown = logs.take(4).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.lastRecord,
          style: context.type.label.copyWith(color: p.ink3),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final log in shown)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: p.lineSoft),
                  ),
                  child: Text(
                    log.summary,
                    style: context.type.numeric.copyWith(
                      fontSize: 12,
                      color: p.ink2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimedPrompt extends StatelessWidget {
  const _TimedPrompt({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('${seconds ~/ 60}분', style: context.type.metric),
          const SizedBox(height: 4),
          Text('시간 슬롯 · 동작은 자율', style: context.type.caption),
        ],
      ),
    );
  }
}
