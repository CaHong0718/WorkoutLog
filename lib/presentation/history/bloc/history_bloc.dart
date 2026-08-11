import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/mvi_bloc.dart';
import '../../../domain/entity/date_range.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/workout_session.dart';
import '../../../domain/usecase/history_usecases.dart';
import 'history_effect.dart';
import 'history_intent.dart';
import 'history_state.dart';

/// Calendar tab: month markers, the tapped day's sessions and the summary.
@injectable
class HistoryBloc extends MviBloc<HistoryIntent, HistoryState, HistoryEffect> {
  HistoryBloc(
    this._getWorkoutDates,
    this._getSessions,
    this._getSessionsOn,
    this._getWeeklyVolume,
    this._getTotalSessionCount,
  ) : super(HistoryState.initial()) {
    on<LoadHistory>(_onLoad, transformer: sequential());
    on<ChangeMonth>(_onChangeMonth, transformer: sequential());
    on<SelectDate>(_onSelectDate, transformer: sequential());
    on<OpenSessionRecord>(_onOpenSession);
  }

  /// 53 weeks — enough to draw the streak without scanning the whole history.
  static const int _streakLookbackDays = 371;

  final GetWorkoutDates _getWorkoutDates;
  final GetSessions _getSessions;
  final GetSessionsOn _getSessionsOn;
  final GetWeeklyVolume _getWeeklyVolume;
  final GetTotalSessionCount _getTotalSessionCount;

  Future<void> _onLoad(LoadHistory intent, Emitter<HistoryState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final datesResult = await _getWorkoutDates(DateRange.month(state.month));
    if (datesResult.isErr) {
      emit(
        state.copyWith(isLoading: false, failure: datesResult.failureOrNull),
      );
      return;
    }

    final dates = datesResult.valueOrNull!;
    final markers = await _markersFor(state.month, dates);
    final total = (await _getTotalSessionCount()).valueOrNull ?? 0;
    final volume = (await _getWeeklyVolume()).valueOrNull ?? const {};
    final streak = await _streakWeeks();

    final selected = state.selectedDate;
    final sessions = selected == null
        ? const <WorkoutSession>[]
        : (await _getSessionsOn(selected)).valueOrNull ?? const [];

    emit(
      state.copyWith(
        isLoading: false,
        hasLoaded: true,
        isMonthLoading: false,
        isDayLoading: false,
        workoutDates: dates,
        dayBodyParts: markers,
        selectedSessions: sessions,
        totalSessions: total,
        weeklyVolume: volume,
        streakWeeks: streak,
      ),
    );
  }

  Future<void> _onChangeMonth(
    ChangeMonth intent,
    Emitter<HistoryState> emit,
  ) async {
    final target = DateTime(state.month.year, state.month.month + intent.delta);
    // Nothing can be recorded in a future month.
    if (target.isAfter(DateTime.now().startOfMonth)) return;

    emit(
      state.copyWith(
        month: target,
        isMonthLoading: true,
        clearSelection: true,
        clearFailure: true,
      ),
    );

    final datesResult = await _getWorkoutDates(DateRange.month(target));
    if (datesResult.isErr) {
      emit(
        state.copyWith(
          isMonthLoading: false,
          failure: datesResult.failureOrNull,
        ),
      );
      return;
    }

    final dates = datesResult.valueOrNull!;
    emit(
      state.copyWith(
        isMonthLoading: false,
        workoutDates: dates,
        dayBodyParts: await _markersFor(target, dates),
      ),
    );
  }

  Future<void> _onSelectDate(
    SelectDate intent,
    Emitter<HistoryState> emit,
  ) async {
    final date = intent.date.dateOnly;
    emit(
      state.copyWith(
        selectedDate: date,
        selectedSessions: const [],
        isDayLoading: true,
      ),
    );

    final result = await _getSessionsOn(date);
    if (result.isErr) {
      emit(state.copyWith(isDayLoading: false));
      emitEffect(ShowHistoryMessage(result.failureOrNull!.message));
      return;
    }
    emit(
      state.copyWith(
        isDayLoading: false,
        selectedSessions: result.valueOrNull ?? const [],
      ),
    );
  }

  void _onOpenSession(OpenSessionRecord intent, Emitter<HistoryState> emit) =>
      emitEffect(OpenSessionDetail(intent.sessionId));

  // ── internals ───────────────────────────────────────────────────────────

  /// Marker color source: the body part that took most sets on each day.
  Future<Map<DateTime, BodyPart>> _markersFor(
    DateTime month,
    Set<DateTime> dates,
  ) async {
    if (dates.isEmpty) return const {};

    final sessions =
        (await _getSessions(DateRange.month(month))).valueOrNull ?? const [];
    final counts = <DateTime, Map<BodyPart, int>>{};

    for (final session in sessions) {
      if (session.status != SessionStatus.completed) continue;
      final date = session.date.dateOnly;
      if (!dates.contains(date)) continue;

      final bucket = counts.putIfAbsent(date, () => <BodyPart, int>{});
      session.volumeByBodyPart.forEach((part, sets) {
        bucket.update(part, (v) => v + sets, ifAbsent: () => sets);
      });
    }

    final markers = <DateTime, BodyPart>{};
    counts.forEach((date, bucket) {
      final part = _dominantBodyPart(bucket);
      if (part != null) markers[date] = part;
    });
    return markers;
  }

  static BodyPart? _dominantBodyPart(Map<BodyPart, int> counts) {
    // Abs is a filler slot on every day, so it never identifies a session.
    final named = counts.entries.where((e) => e.key != BodyPart.abs).toList();
    final pool = named.isEmpty ? counts.entries.toList() : named;
    if (pool.isEmpty) return null;

    pool.sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.index.compareTo(b.key.index);
    });
    return pool.first.key;
  }

  /// Consecutive weeks with at least one completed session, counting back.
  ///
  /// The current week is still running, so an empty one does not break the
  /// chain — counting simply starts from last week.
  Future<int> _streakWeeks() async {
    final today = DateTime.now().dateOnly;
    final result = await _getWorkoutDates(
      DateRange(
        start: DateTime(today.year, today.month, today.day - _streakLookbackDays),
        end: today,
      ),
    );

    final dates = result.valueOrNull;
    if (dates == null || dates.isEmpty) return 0;

    final weeks = dates.map((d) => d.startOfWeek).toSet();
    var cursor = today.startOfWeek;
    if (!weeks.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
    }

    var streak = 0;
    while (weeks.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
    }
    return streak;
  }
}
