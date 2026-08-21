import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/mvi/effect_listener.dart';
import '../../../core/platform/json_file_io.dart';
import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/backup_package.dart';
import '../../common/common_widgets.dart';
import '../../common/metric_tile.dart';
import '../../common/sheet_frame.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_effect.dart';
import '../bloc/backup_intent.dart';
import '../bloc/backup_state.dart';
import '../widget/restore_preview_sheet.dart';

/// Moving the training record out of this phone and back onto another one.
///
/// Reached from the 기록 tab: what is being backed up *is* the record, so it
/// lives next to it rather than in a settings screen the app does not have.
class BackupPage extends StatelessWidget {
  const BackupPage({this.pendingRestore, super.key});

  /// A file shared into the app from elsewhere. Parsed on open, so the user
  /// lands directly on the restore preview.
  final PickedJsonFile? pendingRestore;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<BackupBloc>()..add(const LoadBackupSummary());
        final shared = pendingRestore;
        if (shared != null) {
          bloc.add(
            ReadBackupSource(shared.contents, fileName: shared.fileName),
          );
        }
        return bloc;
      },
      child: const _BackupView(),
    );
  }
}

class _BackupView extends StatelessWidget {
  const _BackupView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupBloc>();

    return EffectListener<BackupEffect>(
      stream: bloc.effects,
      onEffect: _handleEffect,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.backupTitle)),
        body: BlocBuilder<BackupBloc, BackupState>(
          builder: (context, state) {
            if (state.isLoading) return const LoadingView();
            if (state.failure != null) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => bloc.add(const LoadBackupSummary()),
              );
            }
            return _BackupBody(state: state);
          },
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, BackupEffect effect) {
    final bloc = context.read<BackupBloc>();

    switch (effect) {
      case ShowBackupMessage(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));

      case ShowRestorePreview(:final parsed, :final fileName):
        _startRestore(context, bloc, parsed, fileName);

      case ShowRestoreErrors(:final failure, :final fileName):
        showFileErrorSheet(
          context,
          failure: failure,
          title: AppStrings.restoreErrorTitle,
          fileName: fileName,
        );
    }
  }

  Future<void> _startRestore(
    BuildContext context,
    BackupBloc bloc,
    BackupParseResult parsed,
    String? fileName,
  ) async {
    final mode = await RestorePreviewSheet.show(
      context,
      parsed: parsed,
      fileName: fileName,
    );
    if (mode == null || !context.mounted) return;

    // Merging can only add, so it goes straight through. Replacing deletes a
    // training history and gets a second, quantified ask.
    if (mode == BackupRestoreMode.replace) {
      final confirmed = await _confirmReplace(context, bloc.state.summary);
      if (!confirmed || !context.mounted) return;
    }

    bloc.add(ConfirmRestore(parsed.package, mode: mode));
  }

  Future<bool> _confirmReplace(
    BuildContext context,
    BackupSummary current,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.restoreReplaceTitle),
        content: Text(
          '이 기기의 운동 ${current.sessionCount}회 · 세트 ${current.setCount}개가 '
          '지워지고 백업 내용만 남습니다. 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text(AppStrings.restoreReplace),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

class _BackupBody extends StatelessWidget {
  const _BackupBody({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupBloc>();
    final summary = state.summary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenPadding,
        12,
        AppLayout.screenPadding,
        AppLayout.sectionGap,
      ),
      children: [
        Text(AppStrings.backupHint, style: context.type.body),
        const SizedBox(height: 24),

        const Eyebrow(AppStrings.backupOnThisPhone),
        const SizedBox(height: AppLayout.labelGap),
        _SummaryCard(summary: summary),
        const SizedBox(height: AppLayout.sectionGap),

        // One Primary per screen: exporting is the thing this screen is for.
        FilledButton.icon(
          onPressed: state.isBusy || state.isEmpty
              ? null
              : () => bloc.add(const ShareBackupFile()),
          icon: const Icon(Icons.ios_share),
          label: const Text(AppStrings.backupExport),
        ),
        if (state.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppStrings.backupNothingToExport,
              style: context.type.caption,
            ),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: state.isBusy
              ? null
              : () => bloc.add(const PickBackupFile()),
          icon: const Icon(Icons.file_open_outlined),
          label: const Text(AppStrings.backupRestore),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final BackupSummary summary;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: AppStrings.backupSessions,
                  value: '${summary.sessionCount}',
                  unit: '회',
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: AppStrings.backupSets,
                  value: '${summary.setCount}',
                  unit: '개',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: AppStrings.backupRoutines,
                  value: '${summary.routineCount}',
                  unit: '개',
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: AppStrings.backupExercises,
                  value: '${summary.exerciseCount}',
                  unit: '개',
                ),
              ),
            ],
          ),
          if (summary.firstSessionDate != null) ...[
            const SizedBox(height: 16),
            Text(
              '${_day(summary.firstSessionDate!)} ~ '
              '${_day(summary.lastSessionDate!)}',
              style: context.type.caption,
            ),
          ],
        ],
      ),
    );
  }

  static String _day(DateTime value) =>
      '${value.year}.${value.month.toString().padLeft(2, '0')}'
      '.${value.day.toString().padLeft(2, '0')}';
}
