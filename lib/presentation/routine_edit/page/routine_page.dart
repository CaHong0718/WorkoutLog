import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine_day.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/volume_rail.dart';
import '../bloc/routine_bloc.dart';
import '../bloc/routine_effect.dart';
import '../bloc/routine_intent.dart';
import '../bloc/routine_state.dart';
import '../widget/day_meta_sheet.dart';
import '../widget/edit_controls.dart';

/// Routine overview — the entry point of the "루틴" tab.
class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RoutineBloc>()..add(const LoadRoutine()),
      child: const _RoutineView(),
    );
  }
}

class _RoutineView extends StatelessWidget {
  const _RoutineView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RoutineBloc>();

    return EffectListener<RoutineEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.routineEdit),
          actions: [
            IconButton(
              onPressed: () => context.pushNamed(Routes.exerciseLibrary),
              icon: const Icon(Icons.fitness_center_outlined),
              tooltip: AppStrings.exerciseLibrary,
            ),
          ],
        ),
        body: BlocBuilder<RoutineBloc, RoutineState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasRoutine) {
              return const LoadingView();
            }
            if (state.failure != null && !state.hasRoutine) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => bloc.add(const LoadRoutine()),
              );
            }
            if (!state.hasRoutine) {
              return const EmptyView(message: '루틴이 없습니다');
            }
            return _RoutineContent(state: state);
          },
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, RoutineEffect effect) {
    switch (effect) {
      case OpenDayEditor(:final dayId):
        context.pushNamed(
          Routes.dayEdit,
          pathParameters: {'dayId': '$dayId'},
        );
      case ShowRoutineMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _RoutineContent extends StatelessWidget {
  const _RoutineContent({required this.state});

  final RoutineState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RoutineBloc>();
    final days = state.days;

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      buildDefaultDragHandles: false,
      itemCount: days.length,
      onReorderItem: (oldIndex, newIndex) =>
          bloc.add(MoveDay(oldIndex: oldIndex, newIndex: newIndex)),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoutineSummaryCard(state: state),
          const SizedBox(height: 20),
          const Eyebrow('Days'),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              AppStrings.reorderHint,
              style: context.type.caption,
            ),
          ),
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(AppStrings.noDays, style: context.type.caption),
            ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: state.isSaving ? null : () => _addDay(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.addDay),
            ),
            const SizedBox(height: 12),
            Text(
              '순번은 A→B→C→D로 순환합니다. 요일에 묶지 않으므로 하루 빠져도 균형이 유지됩니다.',
              style: context.type.caption,
            ),
          ],
        ),
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        return Padding(
          key: ValueKey(day.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _DayCard(
            day: day,
            index: index,
            onOpen: () => context.pushNamed(
              Routes.dayEdit,
              pathParameters: {'dayId': '${day.id}'},
            ),
            onDelete: () => _deleteDay(context, day),
          ),
        );
      },
    );
  }

  Future<void> _addDay(BuildContext context) async {
    final bloc = context.read<RoutineBloc>();
    final day = await DayMetaSheet.show(
      context,
      isNew: true,
      day: RoutineDay(
        id: RoutineDay.unsavedId,
        routineId: state.routine!.id,
        order: state.days.length,
        code: _nextDayCode(state.days),
        title: '',
        primaryBodyPart: BodyPart.chest,
      ),
    );
    if (day != null) bloc.add(CreateDay(day));
  }

  Future<void> _deleteDay(BuildContext context, RoutineDay day) async {
    final bloc = context.read<RoutineBloc>();
    final confirmed = await confirmDelete(
      context,
      title: 'DAY ${day.code} 삭제',
      message: AppStrings.deleteDayConfirm,
    );
    if (confirmed) bloc.add(RemoveDay(day.id));
  }

  /// First unused letter, so a new day slots into the rotation naturally.
  String _nextDayCode(List<RoutineDay> days) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final used = days.map((day) => day.code.toUpperCase()).toSet();
    for (final letter in alphabet.split('')) {
      if (!used.contains(letter)) return letter;
    }
    return 'D${days.length + 1}';
  }
}

class _RoutineSummaryCard extends StatelessWidget {
  const _RoutineSummaryCard({required this.state});

  final RoutineState state;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final routine = state.routine!;
    final volume = state.weeklyVolume;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      accent: p.accentFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(routine.name, style: context.type.sectionTitle),
          if (routine.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                routine.description!,
                style: context.type.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(value: '${routine.dayCount}', unit: AppStrings.dayCount),
              _Metric(value: '${state.weeklySets}', unit: AppStrings.weeklySets),
              _Metric(
                value: '${routine.sessionMinutes}',
                unit: AppStrings.estimatedTime,
              ),
            ],
          ),
          const SizedBox(height: 16),
          VolumeRail(segments: _segments(context, volume)),
        ],
      ),
    );
  }

  List<RailSegment> _segments(BuildContext context, Map<BodyPart, int> volume) {
    final entries = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in entries)
        RailSegment(
          flex: entry.value,
          color: entry.key.color(context),
          label: '${entry.key.label} ${entry.value}',
        ),
    ];
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.type.metric.copyWith(fontSize: 26)),
          const SizedBox(height: 3),
          Text(unit, style: context.type.label),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.index,
    required this.onOpen,
    required this.onDelete,
  });

  final RoutineDay day;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = day.primaryBodyPart.color(context);
    final volume = day.volumeByBodyPart.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SectionCard(
      accent: accent,
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              day.code,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.title, style: context.type.cardTitle),
                const SizedBox(height: 2),
                Text(
                  '${day.blocks.length}블록 · ${day.totalSets}세트 · '
                  '${day.estimatedMinutes}분',
                  style: context.type.caption,
                ),
                if (volume.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final entry in volume.take(4))
                        BodyPartChip(
                          entry.key,
                          trailing: '${entry.value}',
                          dense: true,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                visualDensity: VisualDensity.compact,
                tooltip: AppStrings.delete,
              ),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Icon(Icons.drag_handle, size: 20, color: p.ink3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
