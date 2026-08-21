import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/platform/json_file_io.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/sheet_frame.dart';
import '../../common/volume_rail.dart';
import '../bloc/routine_list_bloc.dart';
import '../bloc/routine_list_effect.dart';
import '../bloc/routine_list_intent.dart';
import '../bloc/routine_list_state.dart';
import '../widget/edit_controls.dart';
import '../widget/import_preview_sheet.dart';
import '../widget/routine_meta_sheet.dart';

/// The routine library — every program the user has, and the file traffic in
/// and out of the app.
///
/// The seeded `무분할 40분` is one routine among these, not the app itself.
class RoutineListPage extends StatelessWidget {
  const RoutineListPage({this.pendingImport, super.key});

  /// A file shared into the app from elsewhere. Parsed on open, so the user
  /// lands directly on the import preview.
  final PickedJsonFile? pendingImport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<RoutineListBloc>()..add(const LoadRoutines());
        final shared = pendingImport;
        if (shared != null) {
          bloc.add(
            ReadRoutineSource(shared.contents, fileName: shared.fileName),
          );
        }
        return bloc;
      },
      child: const _RoutineListView(),
    );
  }
}

class _RoutineListView extends StatelessWidget {
  const _RoutineListView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RoutineListBloc>();

    return EffectListener<RoutineListEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.routineList),
          actions: [
            BlocBuilder<RoutineListBloc, RoutineListState>(
              buildWhen: (a, b) => a.isBusy != b.isBusy,
              builder: (context, state) => IconButton(
                onPressed: state.isBusy
                    ? null
                    : () => bloc.add(const PickRoutineFile()),
                icon: const Icon(Icons.file_open_outlined),
                tooltip: AppStrings.importFromFile,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createRoutine(context),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.newRoutine),
        ),
        body: BlocBuilder<RoutineListBloc, RoutineListState>(
          builder: (context, state) {
            if (state.isLoading && state.isEmpty) return const LoadingView();
            if (state.failure != null && state.isEmpty) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => bloc.add(const LoadRoutines()),
              );
            }
            if (state.isEmpty) {
              return const EmptyView(message: '루틴이 없습니다. 새로 만들거나 파일에서 가져오세요.');
            }
            return _RoutineListBody(state: state);
          },
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, RoutineListEffect effect) {
    final bloc = context.read<RoutineListBloc>();

    switch (effect) {
      case ShowRoutineListMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case ShowImportPreview(:final parsed, :final fileName):
        ImportPreviewSheet.show(
          context,
          parsed: parsed,
          fileName: fileName,
        ).then((activate) {
          if (activate == null) return;
          bloc.add(ConfirmImport(parsed.package, activate: activate));
        });

      case ShowImportErrors(:final failure, :final fileName):
        showFileErrorSheet(context, failure: failure, fileName: fileName);

      case OpenRoutineEditor(:final routineId):
        context.pushNamed(
          Routes.routineDetail,
          pathParameters: {'routineId': '$routineId'},
        );
    }
  }

  Future<void> _createRoutine(BuildContext context) async {
    final bloc = context.read<RoutineListBloc>();
    final routine = await RoutineMetaSheet.show(
      context,
      isNew: true,
      routine: const Routine(
        id: Routine.unsavedId,
        name: '',
        sessionMinutes: 40,
      ),
    );
    if (routine != null) bloc.add(SaveRoutineMeta(routine));
  }
}

class _RoutineListBody extends StatelessWidget {
  const _RoutineListBody({required this.state});

  final RoutineListState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 96),
      children: [
        Text(AppStrings.routineListHint, style: context.type.caption),
        const SizedBox(height: 14),
        for (final routine in state.routines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RoutineCard(routine: routine, canDelete: state.canDelete),
          ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine, required this.canDelete});

  final Routine routine;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bloc = context.read<RoutineListBloc>();
    final volume = routine.weeklyVolumeByBodyPart.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SectionCard(
      accent: routine.isActive ? p.accentFill : null,
      onTap: () => context.pushNamed(
        Routes.routineDetail,
        pathParameters: {'routineId': '${routine.id}'},
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
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
                    Text(routine.name, style: context.type.cardTitle),
                    const SizedBox(height: 3),
                    Text(
                      'DAY ${routine.dayCount}개 · ${routine.weeklySets}세트 · '
                      '1회 ${routine.sessionMinutes}분',
                      style: context.type.caption,
                    ),
                  ],
                ),
              ),
              if (routine.isActive)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _ActiveBadge(),
                ),
            ],
          ),
          if (routine.description != null) ...[
            const SizedBox(height: 8),
            Text(
              routine.description!,
              style: context.type.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (volume.isNotEmpty) ...[
            const SizedBox(height: 12),
            VolumeRail(
              height: 22,
              segments: [
                for (final entry in volume)
                  RailSegment(
                    flex: entry.value,
                    color: entry.key.color(context),
                    label: '${entry.key.label} ${entry.value}',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              if (!routine.isActive)
                TextButton(
                  onPressed: () => bloc.add(ActivateRoutine(routine.id)),
                  child: const Text(AppStrings.activateRoutine),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => _editMeta(context),
                icon: const Icon(Icons.edit_outlined, size: 19),
                visualDensity: VisualDensity.compact,
                tooltip: AppStrings.routineInfo,
              ),
              IconButton(
                onPressed: () => bloc.add(CopyRoutine(routine.id)),
                icon: const Icon(Icons.copy_outlined, size: 19),
                visualDensity: VisualDensity.compact,
                tooltip: AppStrings.duplicateRoutine,
              ),
              IconButton(
                onPressed: () => bloc.add(ShareRoutine(routine.id)),
                icon: const Icon(Icons.ios_share_outlined, size: 19),
                visualDensity: VisualDensity.compact,
                tooltip: AppStrings.exportRoutine,
              ),
              if (canDelete)
                IconButton(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline, size: 19),
                  visualDensity: VisualDensity.compact,
                  tooltip: AppStrings.delete,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editMeta(BuildContext context) async {
    final bloc = context.read<RoutineListBloc>();
    final edited = await RoutineMetaSheet.show(context, routine: routine);
    if (edited != null) bloc.add(SaveRoutineMeta(edited));
  }

  Future<void> _delete(BuildContext context) async {
    final bloc = context.read<RoutineListBloc>();
    final confirmed = await confirmDelete(
      context,
      title: '${routine.name} 삭제',
      message: AppStrings.deleteRoutineConfirm,
    );
    if (confirmed) bloc.add(RemoveRoutine(routine.id));
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: p.accentFill.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.accentFill.withValues(alpha: 0.4)),
      ),
      child: Text(
        AppStrings.activeRoutine,
        style: context.type.label.copyWith(color: p.accentFill),
      ),
    );
  }
}
