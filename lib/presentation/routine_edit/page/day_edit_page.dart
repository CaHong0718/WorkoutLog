import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/routine_item.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/day_edit_bloc.dart';
import '../bloc/day_edit_effect.dart';
import '../bloc/day_edit_intent.dart';
import '../bloc/day_edit_state.dart';
import '../widget/block_edit_sheet.dart';
import '../widget/block_editor_card.dart';
import '../widget/block_reorder_sheet.dart';
import '../widget/day_meta_sheet.dart';
import '../widget/edit_controls.dart';
import '../widget/exercise_picker_sheet.dart';
import '../widget/item_edit_sheet.dart';

/// Detail editor for one rotation day: meta, blocks and exercise slots.
class DayEditPage extends StatelessWidget {
  const DayEditPage({required this.dayId, super.key});

  final int dayId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DayEditBloc>(param1: dayId)..add(const LoadDay()),
      child: const _DayEditView(),
    );
  }
}

class _DayEditView extends StatelessWidget {
  const _DayEditView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DayEditBloc>();

    return EffectListener<DayEditEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: BlocBuilder<DayEditBloc, DayEditState>(
        builder: (context, state) {
          final day = state.day;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                day == null ? AppStrings.dayEditTitle : 'DAY ${day.code}',
              ),
              actions: [
                IconButton(
                  onPressed: () => _openLibrary(context),
                  icon: const Icon(Icons.fitness_center_outlined),
                  tooltip: AppStrings.exerciseLibrary,
                ),
                if (day != null && day.blocks.length > 1)
                  IconButton(
                    onPressed: () => BlockReorderSheet.show(
                      context,
                      blocks: day.blocks,
                      onReorder: (oldIndex, newIndex) => bloc.add(
                        MoveBlock(oldIndex: oldIndex, newIndex: newIndex),
                      ),
                    ),
                    icon: const Icon(Icons.swap_vert),
                    tooltip: AppStrings.blockOrder,
                  ),
              ],
              bottom: state.isSaving
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(2),
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  : null,
            ),
            body: switch (state) {
              DayEditState(isLoading: true, day: null) => const LoadingView(),
              DayEditState(day: null, failure: final failure?) => ErrorView(
                message: failure.message,
                onRetry: () => bloc.add(const LoadDay()),
              ),
              DayEditState(day: null) => const EmptyView(),
              _ => _DayEditContent(state: state),
            },
          );
        },
      ),
    );
  }

  void _handleEffect(BuildContext context, DayEditEffect effect) {
    switch (effect) {
      case ShowDayEditMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// The library may add or rename exercises, so refresh on the way back.
  Future<void> _openLibrary(BuildContext context) async {
    final bloc = context.read<DayEditBloc>();
    await context.pushNamed(Routes.exerciseLibrary);
    bloc.add(const LoadDay());
  }
}

class _DayEditContent extends StatelessWidget {
  const _DayEditContent({required this.state});

  final DayEditState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DayEditBloc>();
    final day = state.day!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _DayMetaCard(day: day, onEdit: () => _editMeta(context, day)),
        const SizedBox(height: 20),
        const Eyebrow('Blocks'),
        const SizedBox(height: 12),
        if (day.blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(AppStrings.noBlocks, style: context.type.caption),
          ),
        for (final block in day.blocks) ...[
          BlockEditorCard(
            key: ValueKey(block.id),
            block: block,
            alternativesOf: state.alternativesOf,
            onEditBlock: () => _editBlock(context, block),
            onDeleteBlock: () => _deleteBlock(context, block),
            onAddItem: () => _addItem(context, block),
            onEditItem: (item) => _editItem(context, block, item),
            onDeleteItem: (item) => _deleteItem(context, item),
            onReorderItems: (oldIndex, newIndex) => bloc.add(
              MoveItem(
                blockId: block.id,
                oldIndex: oldIndex,
                newIndex: newIndex,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: state.isSaving
              ? null
              : () => bloc.add(const CreateBlock()),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AppStrings.addBlock),
        ),
        const SizedBox(height: 14),
        Text(AppStrings.cutRuleHint, style: context.type.caption),
      ],
    );
  }

  Future<void> _editMeta(BuildContext context, RoutineDay day) async {
    final bloc = context.read<DayEditBloc>();
    final edited = await DayMetaSheet.show(context, day: day, isNew: false);
    if (edited != null) bloc.add(SaveDayMeta(edited));
  }

  Future<void> _editBlock(BuildContext context, RoutineBlock block) async {
    final bloc = context.read<DayEditBloc>();
    final edited = await BlockEditSheet.show(context, block: block);
    if (edited != null) bloc.add(SaveBlock(edited));
  }

  Future<void> _deleteBlock(BuildContext context, RoutineBlock block) async {
    final bloc = context.read<DayEditBloc>();
    final confirmed = await confirmDelete(
      context,
      title: '${block.label} 삭제',
      message: AppStrings.deleteBlockConfirm,
    );
    if (confirmed) bloc.add(RemoveBlock(block.id));
  }

  Future<void> _addItem(BuildContext context, RoutineBlock block) async {
    final bloc = context.read<DayEditBloc>();
    final exercise = await ExercisePickerSheet.show(
      context,
      exercises: state.exercises,
      title: AppStrings.addExercise,
      subtitle: '${block.label} 블록에 추가합니다.',
      excludedIds: block.items.map((item) => item.exerciseId).toSet(),
    );
    if (exercise != null) {
      bloc.add(CreateItem(blockId: block.id, exercise: exercise));
    }
  }

  Future<void> _editItem(
    BuildContext context,
    RoutineBlock block,
    RoutineItem item,
  ) async {
    final bloc = context.read<DayEditBloc>();
    final edited = await ItemEditSheet.show(
      context,
      item: item,
      exercises: state.exercises,
      blockRestSeconds: block.restSeconds,
    );
    if (edited != null) bloc.add(SaveItem(edited));
  }

  Future<void> _deleteItem(BuildContext context, RoutineItem item) async {
    final bloc = context.read<DayEditBloc>();
    final confirmed = await confirmDelete(
      context,
      title: '${item.exercise.name} 삭제',
      message: AppStrings.deleteItemConfirm,
    );
    if (confirmed) bloc.add(RemoveItem(item.id));
  }
}

class _DayMetaCard extends StatelessWidget {
  const _DayMetaCard({required this.day, required this.onEdit});

  final RoutineDay day;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accent = day.primaryBodyPart.color(context);

    return SectionCard(
      accent: accent,
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.fullTitle, style: context.type.sectionTitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        BodyPartChip(day.primaryBodyPart, dense: true),
                        const SizedBox(width: 8),
                        Text(
                          '${day.totalSets}세트 · ${day.estimatedMinutes}분',
                          style: context.type.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: AppStrings.edit,
              ),
            ],
          ),
          if (day.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Text(day.description!, style: context.type.body),
            ),
        ],
      ),
    );
  }
}
