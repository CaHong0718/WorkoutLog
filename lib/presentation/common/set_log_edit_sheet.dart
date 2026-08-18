import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entity/set_log.dart';
import 'body_part_ui.dart';
import 'set_inputs.dart';

/// What the athlete chose to do with an already-recorded set.
sealed class SetLogEditResult {
  const SetLogEditResult();
}

/// Keep the set, with these numbers.
final class SetLogSaved extends SetLogEditResult {
  const SetLogSaved(this.log);

  final SetLog log;
}

/// Drop the row entirely — the set is not part of the session any more.
final class SetLogRemoved extends SetLogEditResult {
  const SetLogRemoved(this.setLogId);

  final int setLogId;
}

/// Edits one recorded set: weight, reps, RIR, or whether it counted at all.
///
/// Used from both the live session timeline and the finished-record detail,
/// so a mistyped number is fixed the same way in either place instead of
/// forcing the athlete to delete and redo the whole thing.
class SetLogEditSheet extends StatefulWidget {
  const SetLogEditSheet({required this.log, super.key});

  final SetLog log;

  static Future<SetLogEditResult?> show(BuildContext context, SetLog log) =>
      showModalBottomSheet<SetLogEditResult>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SetLogEditSheet(log: log),
        ),
      );

  @override
  State<SetLogEditSheet> createState() => _SetLogEditSheetState();
}

class _SetLogEditSheetState extends State<SetLogEditSheet> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  late final TextEditingController _duration;
  late int? _rir;
  late bool _isCompleted;

  /// Time slots (복근 등) carry a duration instead of load × reps.
  bool get _isTimed =>
      widget.log.durationSeconds != null &&
      widget.log.weight == null &&
      widget.log.reps == null;

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    _weight = TextEditingController(
      text: log.isBodyweight ? '' : trimWeight(log.weight!),
    );
    _reps = TextEditingController(text: log.reps?.toString() ?? '');
    _duration = TextEditingController(
      text: (log.durationSeconds ?? 0).toString(),
    );
    _rir = log.rir;
    _isCompleted = log.isCompleted;
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _bumpWeight(double delta) {
    final current = double.tryParse(_weight.text) ?? 0;
    _weight.text = trimWeight((current + delta).clamp(0.0, 999.0));
  }

  void _bumpReps(int delta) {
    final current = int.tryParse(_reps.text) ?? 0;
    _reps.text = '${(current + delta).clamp(0, 999)}';
  }

  void _bumpDuration(int delta) {
    final current = int.tryParse(_duration.text) ?? 0;
    _duration.text = '${(current + delta).clamp(0, 7200)}';
  }

  void _save() {
    final log = widget.log;
    final edited = _isTimed
        ? log.copyWith(
            durationSeconds: int.tryParse(_duration.text) ?? 0,
            rir: _rir,
            isCompleted: _isCompleted,
            clearRir: _rir == null,
          )
        : log.copyWith(
            weight: isBodyweightInput(_weight.text)
                ? null
                : double.tryParse(_weight.text),
            reps: int.tryParse(_reps.text),
            rir: _rir,
            isCompleted: _isCompleted,
            clearWeight: isBodyweightInput(_weight.text),
            clearReps: _reps.text.trim().isEmpty,
            clearRir: _rir == null,
          );

    Navigator.of(context).pop(SetLogSaved(edited));
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteSet),
        content: const Text(AppStrings.deleteSetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false) navigator.pop(SetLogRemoved(widget.log.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final log = widget.log;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.editSet, style: context.type.sectionTitle),
            const SizedBox(height: 10),
            Row(
              children: [
                BodyPartBar(log.bodyPart, height: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.exerciseName,
                    style: context.type.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${log.blockLabel} · ${log.setIndex}${AppStrings.setUnit}',
                  style: context.type.label.copyWith(color: p.ink3),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_isTimed)
              SetNumberRow(
                label: AppStrings.durationField,
                suffix: '초',
                controller: _duration,
                onDecrement: () => _bumpDuration(-30),
                onIncrement: () => _bumpDuration(30),
              )
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
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.countThisSet, style: context.type.body),
                      Text(
                        AppStrings.countThisSetHint,
                        style: context.type.caption,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isCompleted,
                  onChanged: (value) => setState(() => _isCompleted = value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text(AppStrings.deleteSet),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: const Text(AppStrings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
