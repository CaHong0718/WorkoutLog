import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine_block.dart';
import 'edit_controls.dart';

/// Edits one block: its label, its type and its time budget.
class BlockEditSheet extends StatefulWidget {
  const BlockEditSheet({required this.block, super.key});

  final RoutineBlock block;

  static Future<RoutineBlock?> show(
    BuildContext context, {
    required RoutineBlock block,
  }) => showModalBottomSheet<RoutineBlock>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlockEditSheet(block: block),
  );

  @override
  State<BlockEditSheet> createState() => _BlockEditSheetState();
}

class _BlockEditSheetState extends State<BlockEditSheet> {
  late final TextEditingController _label = TextEditingController(
    text: widget.block.label,
  );
  late final TextEditingController _name = TextEditingController(
    text: widget.block.name ?? '',
  );
  late BlockType _type = widget.block.type;
  late int _rounds = widget.block.rounds < 2 ? 3 : widget.block.rounds;
  late int _restSeconds = widget.block.restSeconds;

  /// 0 means "no budget" — stored as null.
  late int _targetMinutes = widget.block.targetMinutes ?? 0;
  late bool _isCuttable = widget.block.isCuttable;

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();

    Navigator.of(context).pop(
      widget.block.copyWith(
        label: _label.text.trim(),
        name: name.isEmpty ? null : name,
        clearName: name.isEmpty,
        type: _type,
        rounds: _type == BlockType.superset ? _rounds : 1,
        restSeconds: _restSeconds,
        targetMinutes: _targetMinutes == 0 ? null : _targetMinutes,
        clearTargetMinutes: _targetMinutes == 0,
        isCuttable: _isCuttable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isSuperset = _type == BlockType.superset;

    return EditSheet(
      title: '블록 편집',
      subtitle: AppStrings.cutRuleHint,
      onSave: _label.text.trim().isEmpty ? null : _save,
      children: [
        TextField(
          controller: _label,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: AppStrings.blockLabel,
            hintText: 'B1',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: AppStrings.blockName,
            hintText: '메인 — 오늘의 약점',
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.blockTypeField, style: context.type.label),
        const SizedBox(height: 8),
        SegmentedButton<BlockType>(
          segments: const [
            ButtonSegment(
              value: BlockType.straight,
              label: Text('일반'),
              icon: Icon(Icons.remove, size: 16),
            ),
            ButtonSegment(
              value: BlockType.superset,
              label: Text('슈퍼세트'),
              icon: Icon(Icons.swap_vert, size: 16),
            ),
          ],
          selected: {_type},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _type = selection.first),
        ),
        if (isSuperset) ...[
          const SizedBox(height: 6),
          Text(AppStrings.supersetRoundsHint, style: context.type.caption),
          NumberStepper(
            label: AppStrings.roundCount,
            value: _rounds,
            min: 2,
            max: 10,
            onChanged: (value) => setState(() => _rounds = value),
          ),
        ],
        const SizedBox(height: 8),
        NumberStepper(
          label: AppStrings.restSeconds,
          value: _restSeconds,
          step: 15,
          max: 300,
          suffix: 's',
          onChanged: (value) => setState(() => _restSeconds = value),
        ),
        NumberStepper(
          label: AppStrings.targetMinutes,
          value: _targetMinutes,
          max: 60,
          suffix: '′',
          onChanged: (value) => setState(() => _targetMinutes = value),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _targetMinutes == 0 ? '0은 목표 시간 없음입니다.' : '',
            style: context.type.caption,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: _isCuttable,
          onChanged: (value) => setState(() => _isCuttable = value),
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.cuttable, style: context.type.body),
          subtitle: Text(
            _isCuttable ? '시간이 모자라면 이 블록부터 잘립니다.' : '그날의 메인 — 절대 자르지 않습니다.',
            style: context.type.caption.copyWith(
              color: _isCuttable ? null : p.warn,
            ),
          ),
        ),
      ],
    );
  }
}
