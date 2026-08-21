import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/platform/json_file_io.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/backup_package.dart';
import '../../../domain/usecase/backup_usecases.dart';
import 'backup_effect.dart';
import 'backup_intent.dart';
import 'backup_state.dart';

/// Moving the whole training record in and out of the app
/// (`docs/07-BACKUP.md`).
///
/// Restore is deliberately three steps — parse, preview, choose a mode — so a
/// wrong file is caught before it becomes rows, and 덮어쓰기 is never one tap
/// away from a year of history.
@injectable
class BackupBloc extends MviBloc<BackupIntent, BackupState, BackupEffect> {
  BackupBloc(
    this._getSummary,
    this._parseBackupFile,
    this._exportBackup,
    this._importBackup,
    this._fileIo,
  ) : super(const BackupState()) {
    on<LoadBackupSummary>(_onLoad);
    on<ShareBackupFile>(_onShare, transformer: sequential());
    on<PickBackupFile>(_onPickFile, transformer: sequential());
    on<ReadBackupSource>(_onReadSource, transformer: sequential());
    on<ConfirmRestore>(_onConfirmRestore, transformer: sequential());
  }

  final GetBackupSummary _getSummary;
  final ParseBackupFile _parseBackupFile;
  final ExportBackup _exportBackup;
  final ImportBackup _importBackup;
  final JsonFileIo _fileIo;

  Future<void> _onLoad(LoadBackupSummary intent, Emitter<BackupState> emit) =>
      _refresh(emit);

  Future<void> _refresh(Emitter<BackupState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    switch (await _getSummary()) {
      case Ok(:final value):
        emit(
          state.copyWith(
            isLoading: false,
            summary: value,
            clearFailure: true,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onShare(
    ShareBackupFile intent,
    Emitter<BackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final result = await _exportBackup();
    switch (result) {
      case Ok(:final value):
        final shared = await _fileIo.shareJsonFile(
          fileName: value.fileName,
          contents: value.contents,
        );
        emit(state.copyWith(isBusy: false));
        if (!shared) {
          emitEffect(const ShowBackupMessage(AppStrings.exportFailed));
        }
      case Err(:final failure):
        emit(state.copyWith(isBusy: false));
        emitEffect(ShowBackupMessage(failure.message));
    }
  }

  Future<void> _onPickFile(
    PickBackupFile intent,
    Emitter<BackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final picked = await _fileIo.pickJsonFile(
      maxBytes: JsonFileIo.backupMaxBytes,
    );
    emit(state.copyWith(isBusy: false));

    if (picked == null) return; // cancelled, or unreadable — already logged
    add(ReadBackupSource(picked.contents, fileName: picked.fileName));
  }

  Future<void> _onReadSource(
    ReadBackupSource intent,
    Emitter<BackupState> emit,
  ) async {
    switch (_parseBackupFile(intent.contents)) {
      case Ok(:final value):
        emitEffect(ShowRestorePreview(value, fileName: intent.fileName));
      case Err(:final failure):
        if (failure is RoutineFormatFailure) {
          emitEffect(ShowRestoreErrors(failure, fileName: intent.fileName));
        } else {
          emitEffect(ShowBackupMessage(failure.message));
        }
    }
  }

  Future<void> _onConfirmRestore(
    ConfirmRestore intent,
    Emitter<BackupState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final result = await _importBackup(intent.package, mode: intent.mode);
    emit(state.copyWith(isBusy: false));

    switch (result) {
      case Ok(:final value):
        emitEffect(ShowBackupMessage(_reportOf(value)));
        await _refresh(emit);
      case Err(:final failure):
        emitEffect(ShowBackupMessage(failure.message));
    }
  }

  String _reportOf(BackupImportReport report) {
    final parts = <String>['운동 ${report.importedSessions}회'];
    if (report.importedSets > 0) parts.add('세트 ${report.importedSets}개');
    if (report.createdRoutines > 0) parts.add('루틴 ${report.createdRoutines}개');
    if (report.skippedSessions > 0) {
      parts.add('건너뜀 ${report.skippedSessions}회');
    }
    return '${AppStrings.restoreDone} ${parts.join(" · ")}';
  }
}
