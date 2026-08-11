import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/routine_item.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';

/// Block-by-block preview of the selected day, mirroring the plan table of the
/// reference document.
class BlockPreviewList extends StatelessWidget {
  const BlockPreviewList({required this.day, super.key});

  final RoutineDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final block in day.blocks) ...[
          _BlockCard(block: block),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block});

  final RoutineBlock block;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
              const SizedBox(width: 8),
              if (block.name != null)
                Expanded(
                  child: Text(
                    block.name!,
                    style: context.type.caption.copyWith(color: p.ink2),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              if (block.isSuperset)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'SS ×${block.rounds}',
                    style: context.type.label.copyWith(color: p.accent),
                  ),
                ),
              Text(_meta(block), style: context.type.label),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in block.items) _ItemRow(item: item),
          if (!block.isCuttable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '컷 불가 — 그날의 메인',
                style: context.type.label.copyWith(color: p.warn),
              ),
            ),
        ],
      ),
    );
  }

  String _meta(RoutineBlock block) {
    final parts = <String>[
      if (block.targetMinutes != null) '${block.targetMinutes}′',
      if (block.restSeconds > 0) '휴식 ${block.restSeconds}s',
    ];
    return parts.join(' · ');
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final RoutineItem item;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: BodyPartBar(item.bodyPart, height: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.exercise.name,
                  style: context.type.cardTitle.copyWith(fontSize: 14),
                ),
                if (item.exercise.subTarget != null)
                  Text(
                    item.exercise.subTarget!,
                    style: context.type.caption.copyWith(fontSize: 11.5),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              item.prescription,
              style: context.type.numeric.copyWith(
                fontSize: 13.5,
                color: p.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
