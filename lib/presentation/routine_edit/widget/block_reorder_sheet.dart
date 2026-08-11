import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_block.dart';

/// Drag the blocks of a day into a new order.
///
/// Kept in its own sheet instead of making the day editor itself reorderable:
/// the block cards already host a reorderable exercise list, and nesting two
/// drag targets makes both unreliable.
class BlockReorderSheet extends StatefulWidget {
  const BlockReorderSheet({
    required this.blocks,
    required this.onReorder,
    super.key,
  });

  final List<RoutineBlock> blocks;

  /// Indices as delivered by `ReorderableListView.onReorderItem`.
  final void Function(int oldIndex, int newIndex) onReorder;

  static Future<void> show(
    BuildContext context, {
    required List<RoutineBlock> blocks,
    required void Function(int oldIndex, int newIndex) onReorder,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlockReorderSheet(blocks: blocks, onReorder: onReorder),
  );

  @override
  State<BlockReorderSheet> createState() => _BlockReorderSheetState();
}

class _BlockReorderSheetState extends State<BlockReorderSheet> {
  late final List<RoutineBlock> _blocks = [...widget.blocks];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.blockOrder, style: context.type.sectionTitle),
                  const SizedBox(height: 4),
                  Text(AppStrings.reorderHint, style: context.type.caption),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: _blocks.length,
                onReorderItem: (oldIndex, newIndex) {
                  widget.onReorder(oldIndex, newIndex);
                  setState(
                    () => _blocks.insert(newIndex, _blocks.removeAt(oldIndex)),
                  );
                },
                itemBuilder: (context, index) {
                  final block = _blocks[index];
                  return ListTile(
                    key: ValueKey(block.id),
                    dense: true,
                    leading: Text(
                      block.label,
                      style: context.type.numeric.copyWith(color: p.ink2),
                    ),
                    title: Text(
                      block.name ?? '${block.items.length}개 종목',
                      style: context.type.cardTitle,
                    ),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
