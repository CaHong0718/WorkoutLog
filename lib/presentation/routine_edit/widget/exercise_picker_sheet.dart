import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';
import '../../common/body_part_ui.dart';
import 'edit_controls.dart';

/// Body-part filter + search over the exercise library.
///
/// Used both for "add an exercise to this block" and for picking an
/// alternative, so the two never drift apart. The list is passed in rather
/// than queried here — widgets do not talk to use cases.
class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({
    required this.exercises,
    this.title = AppStrings.selectExercise,
    this.subtitle,
    this.excludedIds = const {},
    super.key,
  });

  final List<Exercise> exercises;
  final String title;
  final String? subtitle;

  /// Already used in this slot — hidden from the list.
  final Set<int> excludedIds;

  static Future<Exercise?> show(
    BuildContext context, {
    required List<Exercise> exercises,
    String title = AppStrings.selectExercise,
    String? subtitle,
    Set<int> excludedIds = const {},
  }) => showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ExercisePickerSheet(
      exercises: exercises,
      title: title,
      subtitle: subtitle,
      excludedIds: excludedIds,
    ),
  );

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final TextEditingController _search = TextEditingController();
  BodyPart? _bodyPart;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Exercise> get _visible {
    final needle = _search.text.trim().toLowerCase();
    return widget.exercises.where((exercise) {
      if (widget.excludedIds.contains(exercise.id)) return false;
      if (_bodyPart != null && exercise.bodyPart != _bodyPart) return false;
      if (needle.isEmpty) return true;
      final haystack = [
        exercise.name,
        exercise.subTarget ?? '',
        exercise.equipment ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(needle);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final results = _visible;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: media.size.height * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: context.type.sectionTitle),
                    if (widget.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.subtitle!,
                          style: context.type.caption,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: _search,
                  autofocus: false,
                  onChanged: (_) => setState(() {}),
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
                  value: _bodyPart,
                  includeAll: true,
                  onChanged: (part) => setState(() => _bodyPart = part),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noExercises,
                          style: context.type.caption,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: results.length,
                        itemBuilder: (context, index) =>
                            _ExerciseTile(exercise: results[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final detail = [
      if (exercise.subTarget != null) exercise.subTarget!,
      if (exercise.equipment != null) exercise.equipment!,
    ].join(' · ');

    return ListTile(
      dense: true,
      onTap: () => Navigator.of(context).pop(exercise),
      leading: BodyPartBar(exercise.bodyPart, height: 26),
      title: Text(exercise.name, style: context.type.cardTitle),
      subtitle: detail.isEmpty
          ? null
          : Text(detail, style: context.type.caption),
      trailing: exercise.isCustom
          ? Text(
              AppStrings.customBadge,
              style: context.type.label.copyWith(color: p.accent),
            )
          : null,
    );
  }
}
