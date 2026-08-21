import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/routine_package.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/sheet_frame.dart';
import '../../common/volume_rail.dart';

/// What a routine file contains, shown before anything is written.
///
/// Returns null when dismissed, `false` to add the routine, `true` to add it
/// and switch to it. Importing without this step would make a mistyped file
/// silently become a second copy of the same program.
class ImportPreviewSheet extends StatefulWidget {
  const ImportPreviewSheet({required this.parsed, this.fileName, super.key});

  final RoutineParseResult parsed;
  final String? fileName;

  static Future<bool?> show(
    BuildContext context, {
    required RoutineParseResult parsed,
    String? fileName,
  }) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ImportPreviewSheet(parsed: parsed, fileName: fileName),
  );

  @override
  State<ImportPreviewSheet> createState() => _ImportPreviewSheetState();
}

class _ImportPreviewSheetState extends State<ImportPreviewSheet> {
  bool _activate = false;

  @override
  Widget build(BuildContext context) {
    final package = widget.parsed.package;
    final warnings = widget.parsed.warnings;

    return SheetFrame(
      title: AppStrings.importPreview,
      subtitle: widget.fileName,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: _activate,
            onChanged: (value) => setState(() => _activate = value ?? false),
            title: const Text(AppStrings.importAndActivate),
            subtitle: Text('끄면 목록에만 담아둡니다.', style: context.type.caption),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_activate),
                  child: const Text(AppStrings.importConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        Text(package.name, style: context.type.sectionTitle),
        if (package.description != null) ...[
          const SizedBox(height: 6),
          Text(package.description!, style: context.type.body),
        ],
        const SizedBox(height: 14),
        Text(
          'DAY ${package.dayCount}개 · 총 ${package.totalSets}세트 · '
          '1회 ${package.sessionMinutes}분 · 종목 ${package.exercises.length}개',
          style: context.type.caption,
        ),
        const SizedBox(height: 12),
        VolumeRail(segments: _segments(context, package)),
        const SizedBox(height: 18),
        const Eyebrow('Days'),
        const SizedBox(height: 8),
        for (final day in package.days) _DayRow(day: day),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 18),
          WarningBox(warnings: warnings),
        ],
      ],
    );
  }

  List<RailSegment> _segments(BuildContext context, RoutinePackage package) {
    final entries = package.volumeByBodyPart.entries.toList()
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

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final RoutineDayDraft day;

  @override
  Widget build(BuildContext context) {
    final accent = day.primaryBodyPart.color(context);
    final volume = day.volumeByBodyPart.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        accent: accent,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                day.code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 11),
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
                    const SizedBox(height: 7),
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
          ],
        ),
      ),
    );
  }
}
