import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/platform/routine_file_io.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/routine.dart';
import '../../../domain/usecase/routine_usecases.dart';
import 'routine_list_effect.dart';
import 'routine_list_intent.dart';
import 'routine_list_state.dart';

/// The routine library: which programs exist, which one is in use, and the
/// file traffic in and out of the app.
///
/// Import is deliberately two steps — parse, then confirm — so a mistyped file
/// is caught before it becomes rows in the database.
@injectable
class RoutineListBloc
    extends MviBloc<RoutineListIntent, RoutineListState, RoutineListEffect> {
  RoutineListBloc(
    this._watchRoutines,
    this._setActiveRoutine,
    this._createRoutine,
    this._updateRoutine,
    this._deleteRoutine,
    this._duplicateRoutine,
    this._parseRoutineFile,
    this._importRoutine,
    this._exportRoutine,
    this._fileIo,
  ) : super(const RoutineListState()) {
    on<LoadRoutines>(_onLoad);
    on<ActivateRoutine>(_onActivate, transformer: sequential());
    on<SaveRoutineMeta>(_onSaveMeta, transformer: sequential());
    on<RemoveRoutine>(_onRemove, transformer: sequential());
    on<CopyRoutine>(_onCopy, transformer: sequential());
    on<PickRoutineFile>(_onPickFile, transformer: sequential());
    on<ReadRoutineSource>(_onReadSource, transformer: sequential());
    on<ConfirmImport>(_onConfirmImport, transformer: sequential());
    on<ShareRoutine>(_onShare, transformer: sequential());
  }

  final WatchRoutines _watchRoutines;
  final SetActiveRoutine _setActiveRoutine;
  final CreateRoutine _createRoutine;
  final UpdateRoutine _updateRoutine;
  final DeleteRoutine _deleteRoutine;
  final DuplicateRoutine _duplicateRoutine;
  final ParseRoutineFile _parseRoutineFile;
  final ImportRoutine _importRoutine;
  final ExportRoutine _exportRoutine;
  final RoutineFileIo _fileIo;

  /// The stream handler never completes, so a second [LoadRoutines] would open
  /// a duplicate subscription.
  bool _isWatching = false;

  Future<void> _onLoad(
    LoadRoutines intent,
    Emitter<RoutineListState> emit,
  ) async {
    if (_isWatching) return;
    _isWatching = true;

    emit(state.copyWith(isLoading: true, clearFailure: true));
    await emit.forEach<List<Routine>>(
      _watchRoutines(),
      onData: (routines) => state.copyWith(
        isLoading: false,
        routines: routines,
        clearFailure: true,
      ),
      onError: (error, _) => state.copyWith(
        isLoading: false,
        failure: DatabaseFailure('루틴 목록을 불러오지 못했습니다.', cause: error),
      ),
    );
    _isWatching = false;
  }

  Future<void> _onActivate(
    ActivateRoutine intent,
    Emitter<RoutineListState> emit,
  ) => _write(
    emit,
    () => _setActiveRoutine(intent.routineId),
    onOk: AppStrings.routineActivated,
  );

  Future<void> _onSaveMeta(
    SaveRoutineMeta intent,
    Emitter<RoutineListState> emit,
  ) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    if (intent.routine.id == Routine.unsavedId) {
      final created = await _createRoutine(intent.routine);
      emit(state.copyWith(isBusy: false));
      switch (created) {
        case Ok(:final value):
          // A new routine has no days yet; drop the user straight into the
          // editor rather than leaving them on an empty card.
          emitEffect(OpenRoutineEditor(value));
        case Err(:final failure):
          emitEffect(ShowRoutineListMessage(failure.message));
      }
      return;
    }

    final updated = await _updateRoutine(intent.routine);
    emit(state.copyWith(isBusy: false));
    if (updated.isErr) {
      emitEffect(ShowRoutineListMessage(updated.failureOrNull!.message));
    }
  }

  Future<void> _onRemove(
    RemoveRoutine intent,
    Emitter<RoutineListState> emit,
  ) => _write(
    emit,
    () => _deleteRoutine(intent.routineId),
    onOk: AppStrings.routineDeleted,
  );

  Future<void> _onCopy(CopyRoutine intent, Emitter<RoutineListState> emit) =>
      _write(
        emit,
        () => _duplicateRoutine(intent.routineId),
        onOk: AppStrings.routineDuplicated,
      );

  Future<void> _onPickFile(
    PickRoutineFile intent,
    Emitter<RoutineListState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final picked = await _fileIo.pickRoutineFile();
    emit(state.copyWith(isBusy: false));

    if (picked == null) return; // cancelled, or unreadable — already logged
    add(ReadRoutineSource(picked.contents, fileName: picked.fileName));
  }

  Future<void> _onReadSource(
    ReadRoutineSource intent,
    Emitter<RoutineListState> emit,
  ) async {
    switch (_parseRoutineFile(intent.contents)) {
      case Ok(:final value):
        emitEffect(ShowImportPreview(value, fileName: intent.fileName));
      case Err(:final failure):
        if (failure is RoutineFormatFailure) {
          emitEffect(ShowImportErrors(failure, fileName: intent.fileName));
        } else {
          emitEffect(ShowRoutineListMessage(failure.message));
        }
    }
  }

  Future<void> _onConfirmImport(
    ConfirmImport intent,
    Emitter<RoutineListState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final result = await _importRoutine(
      intent.package,
      activate: intent.activate,
    );
    emit(state.copyWith(isBusy: false));

    switch (result) {
      case Ok(:final value):
        emitEffect(
          ShowRoutineListMessage(
            '${value.name} · DAY ${value.dayCount}개를 추가했습니다.',
          ),
        );
      case Err(:final failure):
        emitEffect(ShowRoutineListMessage(failure.message));
    }
  }

  Future<void> _onShare(
    ShareRoutine intent,
    Emitter<RoutineListState> emit,
  ) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final result = await _exportRoutine(intent.routineId);
    switch (result) {
      case Ok(:final value):
        final shared = await _fileIo.shareRoutineFile(
          fileName: value.fileName,
          contents: value.contents,
        );
        emit(state.copyWith(isBusy: false));
        if (!shared) emitEffect(const ShowRoutineListMessage(AppStrings.exportFailed));
      case Err(:final failure):
        emit(state.copyWith(isBusy: false));
        emitEffect(ShowRoutineListMessage(failure.message));
    }
  }

  /// Shared shape of the write handlers: guard, flag, report.
  Future<void> _write(
    Emitter<RoutineListState> emit,
    Future<Result<Object?>> Function() action, {
    required String onOk,
  }) async {
    if (state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    final result = await action();
    emit(state.copyWith(isBusy: false));

    emitEffect(
      ShowRoutineListMessage(
        result.isOk ? onOk : result.failureOrNull!.message,
      ),
    );
  }
}
