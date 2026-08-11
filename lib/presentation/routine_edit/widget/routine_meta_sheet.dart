import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entity/routine.dart';
import 'edit_controls.dart';

/// Edits what a routine *is*: its name, the idea behind it, and how long one
/// session should take. Days are edited on their own screen.
class RoutineMetaSheet extends StatefulWidget {
  const RoutineMetaSheet({required this.routine, required this.isNew, super.key});

  final Routine routine;
  final bool isNew;

  static Future<Routine?> show(
    BuildContext context, {
    required Routine routine,
    bool isNew = false,
  }) => showModalBottomSheet<Routine>(
    context: context,
    isScrollControlled: true,
    builder: (_) => RoutineMetaSheet(routine: routine, isNew: isNew),
  );

  @override
  State<RoutineMetaSheet> createState() => _RoutineMetaSheetState();
}

class _RoutineMetaSheetState extends State<RoutineMetaSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.routine.name,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.routine.description ?? '',
  );
  late int _sessionMinutes = widget.routine.sessionMinutes;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _isValid => _name.text.trim().isNotEmpty;

  void _save() {
    final description = _description.text.trim();

    Navigator.of(context).pop(
      widget.routine.copyWith(
        name: _name.text.trim(),
        description: description.isEmpty ? null : description,
        clearDescription: description.isEmpty,
        sessionMinutes: _sessionMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditSheet(
      title: widget.isNew ? AppStrings.newRoutine : AppStrings.routineInfo,
      subtitle: '분할 방식이 바뀌면 새 루틴으로 만드세요. 기존 루틴과 기록은 그대로 남습니다.',
      onSave: _isValid ? _save : null,
      children: [
        TextField(
          controller: _name,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: AppStrings.routineNameField,
            hintText: '상하체 2분할 50분',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: AppStrings.routineDescriptionField,
            hintText: '이 루틴이 무엇을 노리는지 적어두면 나중에 고를 때 도움이 됩니다.',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        NumberStepper(
          label: AppStrings.sessionMinutesField,
          value: _sessionMinutes,
          onChanged: (value) => setState(() => _sessionMinutes = value),
          step: 5,
          min: 10,
          max: 180,
          suffix: '분',
        ),
      ],
    );
  }
}
