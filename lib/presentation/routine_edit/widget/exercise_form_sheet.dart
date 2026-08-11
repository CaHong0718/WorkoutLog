import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';
import 'edit_controls.dart';

/// Adds or edits one entry of the exercise master list.
class ExerciseFormSheet extends StatefulWidget {
  const ExerciseFormSheet({required this.exercise, super.key});

  final Exercise exercise;

  static Future<Exercise?> show(
    BuildContext context, {
    required Exercise exercise,
  }) => showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ExerciseFormSheet(exercise: exercise),
  );

  @override
  State<ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<ExerciseFormSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.exercise.name,
  );
  late final TextEditingController _subTarget = TextEditingController(
    text: widget.exercise.subTarget ?? '',
  );
  late final TextEditingController _equipment = TextEditingController(
    text: widget.exercise.equipment ?? '',
  );
  late BodyPart _bodyPart = widget.exercise.bodyPart;

  @override
  void dispose() {
    _name.dispose();
    _subTarget.dispose();
    _equipment.dispose();
    super.dispose();
  }

  void _save() {
    final subTarget = _subTarget.text.trim();
    final equipment = _equipment.text.trim();

    Navigator.of(context).pop(
      widget.exercise.copyWith(
        name: _name.text.trim(),
        bodyPart: _bodyPart,
        subTarget: subTarget.isEmpty ? null : subTarget,
        clearSubTarget: subTarget.isEmpty,
        equipment: equipment.isEmpty ? null : equipment,
        clearEquipment: equipment.isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.exercise.id == Exercise.unsavedId;

    return EditSheet(
      title: isNew ? AppStrings.newExercise : AppStrings.editExercise,
      subtitle: '부위는 주간 볼륨 집계 기준이 됩니다.',
      onSave: _name.text.trim().isEmpty ? null : _save,
      children: [
        TextField(
          controller: _name,
          autofocus: isNew,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: AppStrings.exerciseNameField,
            hintText: '인클라인 벤치프레스',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subTarget,
          decoration: const InputDecoration(
            labelText: AppStrings.subTargetField,
            hintText: '상부 · 측면 · 사두',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _equipment,
          decoration: const InputDecoration(
            labelText: AppStrings.equipmentField,
            hintText: '스미스머신 · 케이블 · 덤벨',
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.bodyPartField, style: context.type.label),
        const SizedBox(height: 8),
        BodyPartSelector(
          value: _bodyPart,
          onChanged: (part) => setState(() => _bodyPart = part ?? _bodyPart),
        ),
      ],
    );
  }
}
