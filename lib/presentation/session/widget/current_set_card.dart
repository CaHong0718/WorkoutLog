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

/// Weight increment of the stepper buttons — one 1.25 kg plate per side.
const double _weightStep = 2.5;

/// A blank field and a typed `0` both mean the set carried no external load,
/// so both are logged as 맨몸 rather than as `0kg`.
bool _isBodyweightInput(String text) {
  final value = double.tryParse(text);
  return value == null || value == 0;
}

class CompletedSetValues {
  const CompletedSetValues({this.weight, this.reps, this.rir, this.durationSeconds});

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
    super.key,
  });

  final PlannedSet planned;
  final Exercise exercise;

  /// Logs of the same exercise from previous sessions, newest first.
  final List<SetLog> previousLogs;

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
        oldWidget.exercise.id != widget.exercise.id;
    if (changed) _prefill();
  }

  /// Seeds the inputs from the matching set of the previous session so the
  /// common case is a single tap.
  void _prefill() {
    final logs = widget.previousLogs;
    final match =
        logs.where((l) => l.setIndex == widget.planned.setIndex).firstOrNull ??
        logs.firstOrNull;

    _weight.text = (match == null || match.isBodyweight)
        ? ''
        : _trim(match.weight!);
    _reps.text = match?.reps?.toString() ?? _defaultReps();
    _rir = widget.planned.item.targetRir;
    setState(() {});
  }

  String _defaultReps() {
    final item = widget.planned.item;
    return item.repMin?.toString() ?? '';
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _bumpWeight(double delta) {
    final current = double.tryParse(_weight.text) ?? 0;
    final next = (current + delta).clamp(0.0, 999.0);
    _weight.text = _trim(next);
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
        weight: _isBodyweightInput(_weight.text)
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
          Text(widget.exercise.name, style: context.type.title.copyWith(fontSize: 22)),
          const SizedBox(height: 6),
          Row(
            children: [
              BodyPartChip(widget.exercise.bodyPart, trailing: widget.exercise.subTarget),
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
            _NumberRow(
              label: AppStrings.weight,
              suffix: 'kg',
              controller: _weight,
              onDecrement: () => _bumpWeight(-_weightStep),
              onIncrement: () => _bumpWeight(_weightStep),
              decimal: true,
              zeroSuffix: AppStrings.bodyweight,
            ),
            const SizedBox(height: 10),
            _NumberRow(
              label: AppStrings.reps,
              suffix: '회',
              controller: _reps,
              onDecrement: () => _bumpReps(-1),
              onIncrement: () => _bumpReps(1),
            ),
            const SizedBox(height: 12),
            _RirSelector(
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
                    planned.isTimed ? '완료' : '세트 완료',
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

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.suffix,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    this.decimal = false,
    this.zeroSuffix,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool decimal;

  /// Replaces [suffix] while the field is blank or zero, so the weight row can
  /// say 맨몸 instead of kg for a set that carries no load.
  final String? zeroSuffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(label, style: context.type.label),
        ),
        _StepButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 8),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
                ),
              ],
              style: context.type.numeric.copyWith(fontSize: 19),
              decoration: InputDecoration(
                suffixText: zeroSuffix != null && _isBodyweightInput(value.text)
                    ? zeroSuffix
                    : suffix,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StepButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface2,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: p.line),
          ),
          child: Icon(icon, size: 20, color: p.ink2),
        ),
      ),
    );
  }
}

class _RirSelector extends StatelessWidget {
  const _RirSelector({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(AppStrings.rir, style: context.type.label),
        ),
        for (final option in const [0, 1, 2, 3])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _RirChip(
                label: '$option',
                selected: value == option,
                onTap: () => onChanged(value == option ? null : option),
              ),
            ),
          ),
      ],
    );
  }
}

class _RirChip extends StatelessWidget {
  const _RirChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.accentWash : p.surface2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? p.accentFill : p.line),
          ),
          child: Text(
            label,
            style: context.type.numeric.copyWith(
              fontSize: 14,
              color: selected ? p.accent : p.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
