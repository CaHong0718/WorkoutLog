import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../domain/entity/date_range.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise_progress_point.dart';
import '../../../domain/usecase/history_usecases.dart';
import '../../../domain/usecase/routine_usecases.dart';
import 'stats_effect.dart';
import 'stats_intent.dart';
import 'stats_state.dart';

/// Weekly volume against the routine target, plus the per-exercise trend.
@injectable
class StatsBloc extends MviBloc<StatsIntent, StatsState, StatsEffect> {
  StatsBloc(
    this._getActiveRoutine,
    this._getWeeklyVolume,
    this._getSessions,
    this._getExerciseProgress,
  ) : super(StatsState.initial()) {
    on<LoadStats>(_onLoad, transformer: sequential());
    on<ChangeWeek>(_onChangeWeek, transformer: sequential());
    on<SelectTrendExercise>(_onSelectExercise, transformer: sequential());
  }

  /// Half a year of sessions is enough to know what the user actually trains.
  static const int _trendLookbackDays = 180;

  final GetActiveRoutine _getActiveRoutine;
  final GetWeeklyVolume _getWeeklyVolume;
  final GetSessions _getSessions;
  final GetExerciseProgress _getExerciseProgress;

  Future<void> _onLoad(LoadStats intent, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final routineResult = await _getActiveRoutine();
    if (routineResult.isErr) {
      emit(
        state.copyWith(isLoading: false, failure: routineResult.failureOrNull),
      );
      return;
    }
    final routine = routineResult.valueOrNull!;

    final volume = (await _getWeeklyVolume(state.weekStart)).valueOrNull ?? {};
    final exercises = await _trendCandidates();

    final selected =
        state.selectedExerciseId ??
        (exercises.isEmpty ? null : exercises.first.id);
    final progress = await _progressFor(selected);

    emit(
      state.copyWith(
        isLoading: false,
        hasLoaded: true,
        isWeekLoading: false,
        isTrendLoading: false,
        weeklyVolume: volume,
        targetVolume: routine.weeklyVolumeByBodyPart,
        targetSets: routine.weeklySets,
        trendExercises: exercises,
        selectedExerciseId: selected,
        progress: progress,
      ),
    );
  }

  Future<void> _onChangeWeek(
    ChangeWeek intent,
    Emitter<StatsState> emit,
  ) async {
    final start = state.weekStart;
    final target = DateTime(
      start.year,
      start.month,
      start.day + 7 * intent.delta,
    );
    // Nothing can be recorded in a future week.
    if (target.isAfter(DateTime.now().startOfWeek)) return;

    emit(state.copyWith(weekStart: target, isWeekLoading: true));

    final result = await _getWeeklyVolume(target);
    if (result.isErr) {
      emit(state.copyWith(isWeekLoading: false));
      emitEffect(ShowStatsMessage(result.failureOrNull!.message));
      return;
    }
    emit(
      state.copyWith(
        isWeekLoading: false,
        weeklyVolume: result.valueOrNull ?? const {},
      ),
    );
  }

  Future<void> _onSelectExercise(
    SelectTrendExercise intent,
    Emitter<StatsState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedExerciseId: intent.exerciseId,
        progress: const [],
        isTrendLoading: true,
      ),
    );

    final result = await _getExerciseProgress(intent.exerciseId);
    if (result.isErr) {
      emit(state.copyWith(isTrendLoading: false));
      emitEffect(ShowStatsMessage(result.failureOrNull!.message));
      return;
    }
    emit(
      state.copyWith(
        isTrendLoading: false,
        progress: result.valueOrNull ?? const [],
      ),
    );
  }

  // ── internals ───────────────────────────────────────────────────────────

  /// Exercises worth charting: those logged with a weight recently, most
  /// recently trained first. The library itself is not used — an exercise the
  /// user never touched has nothing to plot.
  Future<List<TrendExercise>> _trendCandidates() async {
    final today = DateTime.now().dateOnly;
    final sessions =
        (await _getSessions(
          DateRange(
            start: DateTime(
              today.year,
              today.month,
              today.day - _trendLookbackDays,
            ),
            end: today,
          ),
        )).valueOrNull ??
        const [];

    // getSessions returns newest first, so insertion order is recency order.
    final found = <int, TrendExercise>{};
    for (final session in sessions) {
      if (session.status != SessionStatus.completed) continue;
      for (final log in session.completedLogs) {
        if (log.weight == null) continue;
        found.putIfAbsent(
          log.exerciseId,
          () => TrendExercise(
            id: log.exerciseId,
            name: log.exerciseName,
            bodyPart: log.bodyPart,
          ),
        );
      }
    }
    return found.values.toList();
  }

  Future<List<ExerciseProgressPoint>> _progressFor(int? exerciseId) async {
    if (exerciseId == null) return const [];
    return (await _getExerciseProgress(exerciseId)).valueOrNull ?? const [];
  }
}
