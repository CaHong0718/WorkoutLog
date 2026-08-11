import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/exercise_library_bloc.dart';
import '../bloc/exercise_library_effect.dart';
import '../bloc/exercise_library_intent.dart';
import '../bloc/exercise_library_state.dart';
import '../widget/edit_controls.dart';
import '../widget/exercise_form_sheet.dart';

/// Exercise master data — the source for every routine slot.
class ExerciseLibraryPage extends StatelessWidget {
  const ExerciseLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExerciseLibraryBloc>()..add(const LoadLibrary()),
      child: const _ExerciseLibraryView(),
    );
  }
}

class _ExerciseLibraryView extends StatelessWidget {
  const _ExerciseLibraryView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExerciseLibraryBloc>();

    return EffectListener<ExerciseLibraryEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.exerciseLibrary)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addExercise(context),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.newExercise),
        ),
        body: BlocBuilder<ExerciseLibraryBloc, ExerciseLibraryState>(
          builder: (context, state) {
            if (state.isLoading && state.exercises.isEmpty) {
              return const LoadingView();
            }
            if (state.failure != null && state.exercises.isEmpty) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => bloc.add(const LoadLibrary()),
              );
            }
            return _LibraryContent(state: state);
          },
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, ExerciseLibraryEffect effect) {
    switch (effect) {
      case ShowLibraryMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _addExercise(BuildContext context) async {
    final bloc = context.read<ExerciseLibraryBloc>();
    final created = await ExerciseFormSheet.show(
      context,
      exercise: const Exercise(
        id: Exercise.unsavedId,
        name: '',
        bodyPart: BodyPart.chest,
        isCustom: true,
      ),
    );
    if (created != null) bloc.add(SaveExercise(created));
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent({required this.state});

  final ExerciseLibraryState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ExerciseLibraryBloc>();
    final results = state.visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: TextField(
            onChanged: (query) => bloc.add(SearchLibrary(query)),
            decoration: const InputDecoration(
              hintText: AppStrings.searchExercise,
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BodyPartSelector(
            value: state.bodyPart,
            includeAll: true,
            onChanged: (part) => bloc.add(FilterLibrary(part)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Text(
            '${results.length}개 · ${AppStrings.customBadge} ${state.customCount}개',
            style: context.type.label,
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const EmptyView(
                  message: AppStrings.noExercises,
                  icon: Icons.search_off_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
                  itemCount: results.length,
                  itemBuilder: (context, index) => _ExerciseTile(
                    exercise: results[index],
                    onEdit: () => _editExercise(context, results[index]),
                    onDelete: () => _deleteExercise(context, results[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _editExercise(BuildContext context, Exercise exercise) async {
    final bloc = context.read<ExerciseLibraryBloc>();
    final edited = await ExerciseFormSheet.show(context, exercise: exercise);
    if (edited != null) bloc.add(SaveExercise(edited));
  }

  Future<void> _deleteExercise(BuildContext context, Exercise exercise) async {
    final bloc = context.read<ExerciseLibraryBloc>();
    final confirmed = await confirmDelete(
      context,
      title: '${exercise.name} 삭제',
      message: AppStrings.deleteExerciseConfirm,
    );
    if (confirmed) bloc.add(RemoveExercise(exercise.id));
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final detail = [
      if (exercise.subTarget != null) exercise.subTarget!,
      if (exercise.equipment != null) exercise.equipment!,
    ].join(' · ');

    return ListTile(
      dense: true,
      onTap: onEdit,
      leading: BodyPartBar(exercise.bodyPart, height: 28),
      title: Row(
        children: [
          Flexible(
            child: Text(
              exercise.name,
              style: context.type.cardTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (exercise.isCustom) ...[
            const SizedBox(width: 8),
            Text(
              AppStrings.customBadge,
              style: context.type.label.copyWith(color: p.accent),
            ),
          ],
        ],
      ),
      subtitle: detail.isEmpty
          ? null
          : Text(detail, style: context.type.caption),
      trailing: PopupMenuButton<_LibraryAction>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (action) => switch (action) {
          _LibraryAction.edit => onEdit(),
          _LibraryAction.delete => onDelete(),
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _LibraryAction.edit,
            child: Text(AppStrings.edit),
          ),
          PopupMenuItem(
            value: _LibraryAction.delete,
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

enum _LibraryAction { edit, delete }
