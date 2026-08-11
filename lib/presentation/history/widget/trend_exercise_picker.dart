import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../common/body_part_ui.dart';
import '../bloc/stats_state.dart';

/// Picks which exercise the trend chart draws.
///
/// The list only holds movements that actually appear in the history, so
/// every entry is guaranteed to have something to plot.
class TrendExercisePicker extends StatelessWidget {
  const TrendExercisePicker({
    required this.exercises,
    this.selectedId,
    super.key,
  });

  final List<TrendExercise> exercises;
  final int? selectedId;

  static Future<int?> show(
    BuildContext context, {
    required List<TrendExercise> exercises,
    int? selectedId,
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) =>
        TrendExercisePicker(exercises: exercises, selectedId: selectedId),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = MediaQuery.of(context);

    return SafeArea(
      child: SizedBox(
        height: media.size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: Text(
                AppStrings.selectTrendExercise,
                style: context.type.sectionTitle,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isSelected = exercise.id == selectedId;
                  return ListTile(
                    dense: true,
                    onTap: () => Navigator.of(context).pop(exercise.id),
                    leading: BodyPartBar(exercise.bodyPart, height: 26),
                    title: Text(exercise.name, style: context.type.cardTitle),
                    subtitle: Text(
                      exercise.bodyPart.label,
                      style: context.type.caption,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, size: 18, color: p.accent)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
