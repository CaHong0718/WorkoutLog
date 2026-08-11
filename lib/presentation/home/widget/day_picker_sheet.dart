import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_day.dart';
import '../../common/body_part_ui.dart';

/// Lets the user override the rotation for one session.
class DayPickerSheet extends StatelessWidget {
  const DayPickerSheet({
    required this.days,
    required this.selectedId,
    super.key,
  });

  final List<RoutineDay> days;
  final int selectedId;

  static Future<int?> show(
    BuildContext context, {
    required List<RoutineDay> days,
    required int selectedId,
  }) => showModalBottomSheet<int>(
    context: context,
    builder: (_) => DayPickerSheet(days: days, selectedId: selectedId),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAY 선택', style: context.type.sectionTitle),
                const SizedBox(height: 4),
                Text(
                  '순번은 A→B→C→D로 자동 진행됩니다. 오늘만 다른 DAY를 하려면 선택하세요.',
                  style: context.type.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final day in days)
            ListTile(
              onTap: () => Navigator.of(context).pop(day.id),
              leading: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: day.primaryBodyPart.color(context),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  day.code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(day.title, style: context.type.cardTitle),
              subtitle: Text(
                '${day.totalSets}세트 · ${day.estimatedMinutes}분',
                style: context.type.caption,
              ),
              trailing: day.id == selectedId
                  ? Icon(Icons.check_circle, color: p.accent, size: 20)
                  : null,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
