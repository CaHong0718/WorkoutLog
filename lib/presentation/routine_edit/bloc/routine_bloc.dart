import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/routine.dart';
import '../../../domain/usecase/routine_usecases.dart';
import 'routine_effect.dart';
import 'routine_intent.dart';
import 'routine_state.dart';

/// Routine overview: the day list, its order and its aggregate volume.
///
/// Reads through [WatchActiveRoutine] so edits made inside the day editor
/// are reflected the moment the user comes back.
@injectable
class RoutineBloc extends MviBloc<RoutineIntent, RoutineState, RoutineEffect> {
  RoutineBloc(
    this._watchActiveRoutine,
    this._watchRoutine,
    this._upsertDay,
    this._deleteDay,
    this._reorderDays,
  ) : super(const RoutineState()) {
    on<LoadRoutine>(_onLoad);
    on<CreateDay>(_onCreateDay, transformer: sequential());
    on<RemoveDay>(_onRemoveDay, transformer: sequential());
    on<MoveDay>(_onMoveDay, transformer: sequential());
  }

  final WatchActiveRoutine _watchActiveRoutine;
  final WatchRoutine _watchRoutine;
  final UpsertDay _upsertDay;
  final DeleteDay _deleteDay;
  final ReorderDays _reorderDays;

  /// The stream handler never completes, so a second [LoadRoutine] would open
  /// a duplicate subscription.
  bool _isWatching = false;

  Future<void> _onLoad(LoadRoutine intent, Emitter<RoutineState> emit) async {
    if (_isWatching) return;
    _isWatching = true;

    emit(state.copyWith(isLoading: true, clearFailure: true));
    await emit.forEach<Routine>(
      intent.routineId == null
          ? _watchActiveRoutine()
          : _watchRoutine(intent.routineId!),
      onData: (routine) => state.copyWith(
        isLoading: false,
        routine: routine,
        clearFailure: true,
      ),
      onError: (error, _) => state.copyWith(
        isLoading: false,
        failure: DatabaseFailure('루틴을 불러오지 못했습니다.', cause: error),
      ),
    );
    // The stream ended (error or close) — allow the retry button to resubscribe.
    _isWatching = false;
  }

  Future<void> _onCreateDay(
    CreateDay intent,
    Emitter<RoutineState> emit,
  ) async {
    final routine = state.routine;
    if (routine == null || state.isSaving) return;

    emit(state.copyWith(isSaving: true));
    final result = await _upsertDay(
      intent.day.copyWith(routineId: routine.id, order: routine.days.length),
    );
    emit(state.copyWith(isSaving: false));

    switch (result) {
      case Ok(:final value):
        emitEffect(OpenDayEditor(value));
      case Err(:final failure):
        emitEffect(ShowRoutineMessage(failure.message));
    }
  }

  Future<void> _onRemoveDay(
    RemoveDay intent,
    Emitter<RoutineState> emit,
  ) async {
    final routine = state.routine;
    if (routine == null || state.isSaving) return;

    emit(state.copyWith(isSaving: true));
    final result = await _deleteDay(intent.dayId);
    if (result.isErr) {
      emit(state.copyWith(isSaving: false));
      emitEffect(ShowRoutineMessage(result.failureOrNull!.message));
      return;
    }

    // Close the gap left in the rotation so `order` stays 0-based and dense.
    final remaining = state.days
        .where((day) => day.id != intent.dayId)
        .map((day) => day.id)
        .toList();
    await _reorderDays(routine.id, remaining);

    emit(state.copyWith(isSaving: false));
    emitEffect(const ShowRoutineMessage('DAY를 삭제했습니다.'));
  }

  Future<void> _onMoveDay(MoveDay intent, Emitter<RoutineState> emit) async {
    final routine = state.routine;
    if (routine == null) return;

    final days = [...state.days];
    if (intent.oldIndex < 0 || intent.oldIndex >= days.length) return;
    if (intent.newIndex < 0 || intent.newIndex >= days.length) return;
    if (intent.oldIndex == intent.newIndex) return;

    days.insert(intent.newIndex, days.removeAt(intent.oldIndex));

    // Show the new order immediately; the watch stream confirms it right after.
    emit(state.copyWith(routine: routine.copyWith(days: days)));

    final result = await _reorderDays(
      routine.id,
      days.map((day) => day.id).toList(),
    );
    if (result.isErr) {
      emitEffect(ShowRoutineMessage(result.failureOrNull!.message));
    }
  }
}
