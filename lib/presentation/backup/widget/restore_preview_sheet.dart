import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/backup_package.dart';
import '../../common/common_widgets.dart';
import '../../common/sheet_frame.dart';

/// What a backup file contains, and how to apply it.
///
/// Returns null when dismissed, otherwise the mode the user chose. The two
/// modes are stated as sentences rather than as a pair of same-weight buttons:
/// one adds, the other deletes a training history, and that difference has to
/// be readable before the tap, not after.
class RestorePreviewSheet extends StatelessWidget {
  const RestorePreviewSheet({required this.parsed, this.fileName, super.key});

  final BackupParseResult parsed;
  final String? fileName;

  static Future<BackupRestoreMode?> show(
    BuildContext context, {
    required BackupParseResult parsed,
    String? fileName,
  }) => showModalBottomSheet<BackupRestoreMode>(
    context: context,
    isScrollControlled: true,
    builder: (_) => RestorePreviewSheet(parsed: parsed, fileName: fileName),
  );

  @override
  Widget build(BuildContext context) {
    final package = parsed.package;
    final summary = package.summary;

    return SheetFrame(
      title: AppStrings.restorePreview,
      subtitle: fileName,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow(AppStrings.restoreChooseMode),
          const SizedBox(height: 8),
          ChoiceTile(
            icon: Icons.merge_outlined,
            title: AppStrings.restoreMerge,
            description: AppStrings.restoreMergeHint,
            emphasized: true,
            onTap: () =>
                Navigator.of(context).pop(BackupRestoreMode.merge),
          ),
          const SizedBox(height: 8),
          ChoiceTile(
            icon: Icons.settings_backup_restore,
            title: AppStrings.restoreReplace,
            description: AppStrings.restoreReplaceHint,
            onTap: () =>
                Navigator.of(context).pop(BackupRestoreMode.replace),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
      children: [
        _Counts(summary: summary),
        if (summary.firstSessionDate != null) ...[
          const SizedBox(height: 10),
          Text(
            '${_day(summary.firstSessionDate!)} ~ '
            '${_day(summary.lastSessionDate!)}',
            style: context.type.caption,
          ),
        ],
        if (package.routines.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Eyebrow(AppStrings.backupRoutines),
          const SizedBox(height: 8),
          for (final routine in package.routines) _RoutineRow(routine: routine),
        ],
        if (parsed.warnings.isNotEmpty) ...[
          const SizedBox(height: 18),
          WarningBox(warnings: parsed.warnings),
        ],
      ],
    );
  }

  static String _day(DateTime value) =>
      '${value.year}.${value.month.toString().padLeft(2, '0')}'
      '.${value.day.toString().padLeft(2, '0')}';
}

class _Counts extends StatelessWidget {
  const _Counts({required this.summary});

  final BackupSummary summary;

  @override
  Widget build(BuildContext context) {
    return Text(
      '운동 ${summary.sessionCount}회 · 세트 ${summary.setCount}개 · '
      '루틴 ${summary.routineCount}개 · 종목 ${summary.exerciseCount}개',
      style: context.type.cardTitle,
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.routine});

  final BackupRoutine routine;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final package = routine.package;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package.name, style: context.type.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    'DAY ${package.dayCount}개 · ${package.totalSets}세트',
                    style: context.type.caption,
                  ),
                ],
              ),
            ),
            if (routine.isActive)
              Text(
                AppStrings.activeRoutine,
                style: context.type.label.copyWith(color: p.accent),
              ),
          ],
        ),
      ),
    );
  }
}
