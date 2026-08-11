import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/routine_item.dart';
import '../../common/body_part_ui.dart';
import 'edit_controls.dart';
import 'exercise_picker_sheet.dart';

/// Edits one exercise slot: prescription, rest override, RIR, note and the
/// fallbacks used when the machine is taken.
class ItemEditSheet extends StatefulWidget {
  const ItemEditSheet({
    required this.item,
    required this.exercises,
    required this.blockRestSeconds,
    super.key,
  });

  final RoutineItem item;

  /// Library used by the exercise and alternative pickers.
  final List<Exercise> exercises;

  /// Shown as the fallback when no override is set.
  final int blockRestSeconds;

  static Future<RoutineItem?> show(
    BuildContext context, {
    required RoutineItem item,
    required List<Exercise> exercises,
    required int blockRestSeconds,
  }) => showModalBottomSheet<RoutineItem>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ItemEditSheet(
      item: item,
      exercises: exercises,
      blockRestSeconds: blockRestSeconds,
    ),
  );

  @override
  State<ItemEditSheet> createState() => _ItemEditSheetState();
}

class _ItemEditSheetState extends State<ItemEditSheet> {
  late final TextEditingController _note = TextEditingController(
    text: widget.item.note ?? '',
  );
  late Exercise _exercise = widget.item.exercise;
  late int _sets = widget.item.sets;
  late RepMode _repMode = widget.item.repMode;
  late int _repMin = widget.item.repMin ?? 8;
  late int _repMax = widget.item.repMax ?? 12;
  late int _durationMinutes = (widget.item.durationSeconds ?? 300) ~/ 60;
  late bool _hasRestOverride = widget.item.restSecondsOverride != null;
  late int _restOverride =
      widget.item.restSecondsOverride ?? widget.blockRestSeconds;
  late bool _hasTargetRir = widget.item.targetRir != null;
  late int _targetRir = widget.item.targetRir ?? 2;
  late final List<int> _alternativeIds = [
    ...widget.item.alternativeExerciseIds,
  ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Map<int, Exercise> get _byId => {
    for (final exercise in widget.exercises) exercise.id: exercise,
  };

  void _save() {
    final note = _note.text.trim();
    final isRange = _repMode == RepMode.range;
    final isDuration = _repMode == RepMode.duration;

    Navigator.of(context).pop(
      widget.item.copyWith(
        exercise: _exercise,
        sets: _sets,
        repMode: _repMode,
        repMin: isRange ? _repMin : null,
        repMax: isRange ? _repMax : null,
        clearRepRange: !isRange,
        durationSeconds: isDuration ? _durationMinutes * 60 : null,
        clearDuration: !isDuration,
        restSecondsOverride: _hasRestOverride ? _restOverride : null,
        clearRestOverride: !_hasRestOverride,
        targetRir: _hasTargetRir ? _targetRir : null,
        clearTargetRir: !_hasTargetRir,
        note: note.isEmpty ? null : note,
        clearNote: note.isEmpty,
        alternativeExerciseIds: _alternativeIds,
      ),
    );
  }

  Future<void> _changeExercise() async {
    final picked = await ExercisePickerSheet.show(
      context,
      exercises: widget.exercises,
      title: AppStrings.selectExercise,
    );
    if (picked != null) setState(() => _exercise = picked);
  }

  Future<void> _addAlternative() async {
    final picked = await ExercisePickerSheet.show(
      context,
      exercises: widget.exercises,
      title: AppStrings.addAlternative,
      subtitle: '기구가 없을 때 30초 안에 갈아탈 종목입니다.',
      excludedIds: {_exercise.id, ..._alternativeIds},
    );
    if (picked != null) setState(() => _alternativeIds.add(picked.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final byId = _byId;

    return EditSheet(
      title: _exercise.name,
      subtitle: _exercise.displayName == _exercise.name
          ? null
          : _exercise.displayName,
      onSave: _save,
      children: [
        OutlinedButton.icon(
          onPressed: _changeExercise,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('종목 변경'),
        ),
        const SizedBox(height: 8),
        NumberStepper(
          label: AppStrings.setCount,
          value: _sets,
          min: 1,
          max: 12,
          onChanged: (value) => setState(() => _sets = value),
        ),
        const SizedBox(height: 12),
        Text(AppStrings.repModeField, style: context.type.label),
        const SizedBox(height: 8),
        SegmentedButton<RepMode>(
          segments: const [
            ButtonSegment(
              value: RepMode.range,
              label: Text(AppStrings.repModeRange),
            ),
            ButtonSegment(
              value: RepMode.amrap,
              label: Text(AppStrings.repModeAmrap),
            ),
            ButtonSegment(
              value: RepMode.duration,
              label: Text(AppStrings.repModeDuration),
            ),
          ],
          selected: {_repMode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _repMode = selection.first),
        ),
        if (_repMode == RepMode.range) ...[
          NumberStepper(
            label: AppStrings.repMinField,
            value: _repMin,
            min: 1,
            max: 50,
            onChanged: (value) => setState(() {
              _repMin = value;
              if (_repMax < value) _repMax = value;
            }),
          ),
          NumberStepper(
            label: AppStrings.repMaxField,
            value: _repMax,
            min: 1,
            max: 50,
            onChanged: (value) => setState(() {
              _repMax = value;
              if (_repMin > value) _repMin = value;
            }),
          ),
        ],
        if (_repMode == RepMode.duration)
          NumberStepper(
            label: AppStrings.durationMinutes,
            value: _durationMinutes,
            min: 1,
            max: 30,
            suffix: '분',
            onChanged: (value) => setState(() => _durationMinutes = value),
          ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: !_hasRestOverride,
          onChanged: (value) => setState(() => _hasRestOverride = !value),
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.useBlockRest, style: context.type.body),
          subtitle: Text(
            '블록 기본 ${widget.blockRestSeconds}초',
            style: context.type.caption,
          ),
        ),
        if (_hasRestOverride)
          NumberStepper(
            label: AppStrings.restSeconds,
            value: _restOverride,
            step: 15,
            max: 300,
            suffix: 's',
            onChanged: (value) => setState(() => _restOverride = value),
          ),
        SwitchListTile(
          value: _hasTargetRir,
          onChanged: (value) => setState(() => _hasTargetRir = value),
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.targetRir, style: context.type.body),
          subtitle: Text(AppStrings.legsFirstWeeksHint, style: context.type.caption),
        ),
        if (_hasTargetRir)
          NumberStepper(
            label: AppStrings.targetRir,
            value: _targetRir,
            max: 5,
            onChanged: (value) => setState(() => _targetRir = value),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _note,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: AppStrings.noteField,
            hintText: '반동 금지, 상단 1초 정지',
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.alternatives, style: context.type.label),
        const SizedBox(height: 8),
        if (_alternativeIds.isEmpty)
          Text(AppStrings.noAlternatives, style: context.type.caption)
        else
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              for (final id in _alternativeIds)
                if (byId[id] case final alternative?)
                  InputChip(
                    label: Text(alternative.name),
                    avatar: BodyPartBar(alternative.bodyPart, height: 14),
                    labelStyle: context.type.caption.copyWith(color: p.ink2),
                    onDeleted: () =>
                        setState(() => _alternativeIds.remove(id)),
                    visualDensity: VisualDensity.compact,
                  ),
            ],
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addAlternative,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AppStrings.addAlternative),
        ),
      ],
    );
  }
}
