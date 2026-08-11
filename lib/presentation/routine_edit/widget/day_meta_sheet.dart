import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine_day.dart';
import 'edit_controls.dart';

/// Edits the identity of a rotation day: code, title, subtitle, rationale and
/// the body part that colors it everywhere else in the app.
class DayMetaSheet extends StatefulWidget {
  const DayMetaSheet({required this.day, required this.isNew, super.key});

  final RoutineDay day;
  final bool isNew;

  static Future<RoutineDay?> show(
    BuildContext context, {
    required RoutineDay day,
    bool isNew = false,
  }) => showModalBottomSheet<RoutineDay>(
    context: context,
    isScrollControlled: true,
    builder: (_) => DayMetaSheet(day: day, isNew: isNew),
  );

  @override
  State<DayMetaSheet> createState() => _DayMetaSheetState();
}

class _DayMetaSheetState extends State<DayMetaSheet> {
  late final TextEditingController _code = TextEditingController(
    text: widget.day.code,
  );
  late final TextEditingController _title = TextEditingController(
    text: widget.day.title,
  );
  late final TextEditingController _subtitle = TextEditingController(
    text: widget.day.subtitle ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.day.description ?? '',
  );
  late BodyPart _bodyPart = widget.day.primaryBodyPart;

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _subtitle.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _code.text.trim().isNotEmpty && _title.text.trim().isNotEmpty;

  void _save() {
    final subtitle = _subtitle.text.trim();
    final description = _description.text.trim();

    Navigator.of(context).pop(
      widget.day.copyWith(
        code: _code.text.trim(),
        title: _title.text.trim(),
        subtitle: subtitle.isEmpty ? null : subtitle,
        clearSubtitle: subtitle.isEmpty,
        description: description.isEmpty ? null : description,
        clearDescription: description.isEmpty,
        primaryBodyPart: _bodyPart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditSheet(
      title: widget.isNew ? AppStrings.addDay : AppStrings.dayInfo,
      subtitle: '요일이 아니라 순번입니다. 코드는 A·B·C처럼 짧게 두세요.',
      onSave: _isValid ? _save : null,
      children: [
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: AppStrings.dayCode,
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: AppStrings.dayTitleField,
            hintText: '등 + 이두',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subtitle,
          decoration: const InputDecoration(
            labelText: AppStrings.daySubtitle,
            hintText: '당기기 데이',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: AppStrings.dayDescription,
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.primaryBodyPart, style: context.type.label),
        const SizedBox(height: 8),
        BodyPartSelector(
          value: _bodyPart,
          onChanged: (part) => setState(() => _bodyPart = part ?? _bodyPart),
        ),
      ],
    );
  }
}
