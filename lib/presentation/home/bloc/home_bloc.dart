import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/usecase/history_usecases.dart';
import '../../../domain/usecase/routine_usecases.dart';
import '../../../domain/usecase/workout_usecases.dart';
import 'home_effect.dart';
import 'home_intent.dart';
import 'home_state.dart';

@injectable
class HomeBloc extends MviBloc<HomeIntent, HomeState, HomeEffect> {
  HomeBloc(
    this._getActiveRoutine,
    this._watchActiveRoutine,
    this._getNextDay,
    this._getInProgressSession,
    this._getWeeklyVolume,
    this._startSession,
    this._abortSession,
  ) : super(const HomeState()) {
    on<LoadHome>(_onLoad, transformer: sequential());
    on<SelectDay>(_onSelectDay);
    on<StartWorkout>(_onStartWorkout, transformer: sequential());
    on<ResumeWorkout>(_onResumeWorkout);
    on<DiscardInProgress>(_onDiscardInProgress, transformer: sequential());

    // The shell keeps Home alive, so it is never rebuilt from scratch:
    // switching the active routine from the library, or editing days in the
    // routine tab, would otherwise leave today's card stale.
    // `skip(1)` drops the stream's replay of the current value — the page's own
    // `LoadHome` already covers it.
    _routineChanges = _watchActiveRoutine()
        .skip(1)
        .listen((_) => add(const LoadHome()), onError: (Object _) {});
  }

  final GetActiveRoutine _getActiveRoutine;
  final WatchActiveRoutine _watchActiveRoutine;
  final GetNextDay _getNextDay;
  final GetInProgressSession _getInProgressSession;
  final GetWeeklyVolume _getWeeklyVolume;
  final StartSession _startSession;
  final AbortSession _abortSession;

  late final StreamSubscription<void> _routineChanges;

  @override
  Future<void> close() async {
    await _routineChanges.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadHome intent, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final routineResult = await _getActiveRoutine();
    if (routineResult.isErr) {
      emit(
        state.copyWith(isLoading: false, failure: routineResult.failureOrNull),
      );
      return;
    }
    final routine = routineResult.valueOrNull!;

    // Only a day the user picked by hand survives a refresh. Holding on to
    // whatever was on screen would freeze the rotation: after finishing DAY A
    // the card has to move to DAY B without restarting the app.
    RoutineDay? day;
    final pinnedId = state.pinnedDayId;
    if (pinnedId != null) {
      day = routine.days.where((d) => d.id == pinnedId).firstOrNull;
    }
    // Rotation follows the last *completed* session, whatever date it was on.
    day ??= (await _getNextDay()).valueOrNull;
    day ??= routine.days.firstOrNull;

    final inProgress = (await _getInProgressSession()).valueOrNull;
    final volume = (await _getWeeklyVolume()).valueOrNull ?? const {};

    emit(
      HomeState(
        isLoading: false,
        routine: routine,
        selectedDay: day,
        pinnedDayId: day?.id == pinnedId ? pinnedId : null,
        inProgressSession: inProgress,
        weeklyVolume: volume,
      ),
    );
  }

  void _onSelectDay(SelectDay intent, Emitter<HomeState> emit) {
    final day = state.routine?.days
        .where((d) => d.id == intent.dayId)
        .firstOrNull;
    if (day != null) {
      emit(state.copyWith(selectedDay: day, pinnedDayId: day.id));
    }
  }

  Future<void> _onStartWorkout(
    StartWorkout intent,
    Emitter<HomeState> emit,
  ) async {
    final day = state.selectedDay;
    if (day == null || state.isStarting) return;

    emit(state.copyWith(isStarting: true));
    final result = await _startSession(day.id);

    switch (result) {
      case Ok(:final value):
        // The new session *is* the in-progress one: starting aborts whatever
        // was open. Clearing the field here would hide the resume banner if the
        // user walked away from this session too.
        //
        // The manual pick is spent now — once this session is done the card
        // must show the next day in the rotation, not this one again.
        emit(
          state.copyWith(
            isStarting: false,
            inProgressSession: value,
            clearPinnedDay: true,
          ),
        );
        emitEffect(OpenSession(value.id));
      case Err(:final failure):
        emit(state.copyWith(isStarting: false));
        emitEffect(ShowHomeMessage(failure.message));
    }
  }

  void _onResumeWorkout(ResumeWorkout intent, Emitter<HomeState> emit) {
    final session = state.inProgressSession;
    if (session == null) return;
    emitEffect(OpenSession(session.id));
  }

  Future<void> _onDiscardInProgress(
    DiscardInProgress intent,
    Emitter<HomeState> emit,
  ) async {
    final session = state.inProgressSession;
    if (session == null) return;

    final result = await _abortSession(session.id);
    if (result.isErr) {
      emitEffect(ShowHomeMessage(result.failureOrNull!.message));
      return;
    }
    emit(state.copyWith(clearInProgress: true));
    emitEffect(const ShowHomeMessage('진행 중이던 운동을 중단했습니다.'));
  }
}
