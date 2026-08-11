import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_item.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/drag_proxy.dart';

/// One editable block: header with its budget, then its exercise slots as a
/// drag-reorderable list.
class BlockEditorCard extends StatelessWidget {
  const BlockEditorCard({
    required this.block,
    required this.alternativesOf,
    required this.onEditBlock,
    required this.onDeleteBlock,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onReorderItems,
    super.key,
  });

  final RoutineBlock block;

  /// Resolves an item's alternative ids into exercises for the summary line.
  final List<Exercise> Function(RoutineItem item) alternativesOf;

  final VoidCallback onEditBlock;
  final VoidCallback onDeleteBlock;
  final VoidCallback onAddItem;
  final void Function(RoutineItem item) onEditItem;
  final void Function(RoutineItem item) onDeleteItem;

  /// Indices as delivered by `ReorderableListView.onReorderItem`.
  final void Function(int oldIndex, int newIndex) onReorderItems;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
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
              Expanded(
                child: Text(
                  block.name ?? '',
                  style: context.type.caption.copyWith(color: p.ink2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (block.isSuperset)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    'SS ×${block.rounds}',
                    style: context.type.label.copyWith(color: p.accent),
                  ),
                ),
              Text(_meta(), style: context.type.label),
              PopupMenuButton<_BlockAction>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) => switch (action) {
                  _BlockAction.edit => onEditBlock(),
                  _BlockAction.delete => onDeleteBlock(),
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _BlockAction.edit,
                    child: Text(AppStrings.edit),
                  ),
                  PopupMenuItem(
                    value: _BlockAction.delete,
                    child: Text(AppStrings.delete),
                  ),
                ],
              ),
            ],
          ),
          if (!block.isCuttable)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '컷 불가 — 그날의 메인',
                style: context.type.label.copyWith(color: p.warn),
              ),
            ),
          if (block.items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(AppStrings.noItems, style: context.type.caption),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              padding: EdgeInsets.zero,
              // The rows have no surface of their own, so the lifted one takes
              // a rounded fill rather than the framework's square slab.
              proxyDecorator: roundedDragProxy(
                radius: AppRadius.input,
                filled: true,
              ),
              itemCount: block.items.length,
              onReorderItem: onReorderItems,
              itemBuilder: (context, index) {
                final item = block.items[index];
                return _ItemRow(
                  key: ValueKey(item.id),
                  index: index,
                  item: item,
                  alternatives: alternativesOf(item),
                  onTap: () => onEditItem(item),
                  onDelete: () => onDeleteItem(item),
                );
              },
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.addExercise),
            ),
          ),
        ],
      ),
    );
  }

  String _meta() {
    final parts = <String>[
      if (block.targetMinutes != null) '${block.targetMinutes}′',
      '휴식 ${block.restSeconds}s',
    ];
    return parts.join(' · ');
  }
}

enum _BlockAction { edit, delete }

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.index,
    required this.item,
    required this.alternatives,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final int index;
  final RoutineItem item;
  final List<Exercise> alternatives;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: BodyPartBar(item.bodyPart, height: 16),
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
                  if (item.exercise.subTarget != null || item.note != null)
                    Text(
                      [
                        if (item.exercise.subTarget != null)
                          item.exercise.subTarget!,
                        if (item.note != null) item.note!,
                      ].join(' · '),
                      style: context.type.caption.copyWith(fontSize: 11.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (alternatives.isNotEmpty)
                    Text(
                      '${AppStrings.alternatives} · '
                      '${alternatives.map((e) => e.name).join(', ')}',
                      style: context.type.caption.copyWith(
                        fontSize: 11.5,
                        color: p.ink3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: AppStrings.delete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Icon(Icons.drag_handle, size: 20, color: p.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
