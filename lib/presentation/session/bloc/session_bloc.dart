import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/mvi/mvi_bloc.dart';
import '../../../core/notification/rest_notifier.dart';
import '../../../core/result/result.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/progression_suggestion.dart';
import '../../../domain/entity/session_plan.dart';
import '../../../domain/entity/set_log.dart';
import '../../../domain/usecase/exercise_usecases.dart';
import '../../../domain/usecase/routine_usecases.dart';
import '../../../domain/usecase/workout_usecases.dart';
import 'session_effect.dart';
import 'session_intent.dart';
import 'session_state.dart';

@injectable
class SessionBloc extends MviBloc<SessionIntent, SessionState, SessionEffect> {
  SessionBloc(
    @factoryParam this.sessionId,
    this._getSession,
    this._getDayDetail,
    this._logSet,
    this._updateSet,
    this._deleteSet,
    this._completeSession,
    this._abortSession,
    this._getLastLogsForExercise,
    this._getExercisesByIds,
    this._suggestProgression,
    this._restNotifier,
  ) : super(const SessionState()) {
    on<LoadSession>(_onLoad);
    on<TickSecond>(_onTick);
    on<CompleteCurrentSet>(_onCompleteSet, transformer: sequential());
    on<SkipCurrentSet>(_onSkipSet, transformer: sequential());
    on<SkipBlock>(_onSkipBlock, transformer: sequential());
    on<JumpToSet>(_onJumpToSet, transformer: sequential());
    on<SubstituteExercise>(_onSubstitute);
    on<AddRest>(_onAddRest, transformer: sequential());
    on<SkipRest>(_onSkipRest, transformer: sequential());
    on<EditSetLog>(_onEditLog, transformer: sequential());
    on<DeleteSetLog>(_onDeleteLog, transformer: sequential());
    on<FinishSession>(_onFinish, transformer: sequential());
    on<AbortCurrentSession>(_onAbort, transformer: sequential());
  }

  final int sessionId;
  final GetSession _getSession;
  final GetDayDetail _getDayDetail;
  final LogSet _logSet;
  final UpdateSet _updateSet;
  final DeleteSet _deleteSet;
  final CompleteSession _completeSession;
  final AbortSession _abortSession;
  final GetLastLogsForExercise _getLastLogsForExercise;
  final GetExercisesByIds _getExercisesByIds;
  final SuggestProgression _suggestProgression;
  final RestNotifier _restNotifier;

  Timer? _ticker;

  /// Wall-clock start of the running rest, so the value written to the log is
  /// what the user actually took rather than what was prescribed.
  DateTime? _restStartedAt;
  int? _lastLogId;

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await _restNotifier.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadSession intent, Emitter<SessionState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    // Asked here rather than at launch: standing at the rack is when the
    // request makes sense to the user.
    unawaited(_restNotifier.ensurePermissions());

    final sessionResult = await _getSession(sessionId);
    if (sessionResult.isErr) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: sessionResult.failureOrNull,
        ),
      );
      return;
    }
    final session = sessionResult.valueOrNull!;

    final dayId = session.dayId;
    if (dayId == null) {
      emit(
        state.copyWith(
          isLoading: false,
          session: session,
          failure: sessionResult.failureOrNull,
        ),
      );
      return;
    }

    final dayResult = await _getDayDetail(dayId);
    if (dayResult.isErr) {
      emit(state.copyWith(isLoading: false, failure: dayResult.failureOrNull));
      return;
    }
    final day = dayResult.valueOrNull!;
    final plan = SessionPlan.fromDay(day);

    // Prefill inputs from the last time each exercise was trained.
    final lastLogs = <int, List<SetLog>>{};
    for (final exerciseId in plan.map((p) => p.item.exerciseId).toSet()) {
      final logs = await _getLastLogsForExercise(exerciseId, limit: 6);
      final value = logs.valueOrNull;
      if (value != null && value.isNotEmpty) lastLogs[exerciseId] = value;
    }

    emit(
      SessionState(
        isLoading: false,
        session: session,
        day: day,
        plan: plan,
        currentIndex: SessionPlan.resumeIndex(plan, session.setLogs),
        lastLogs: lastLogs,
        alternatives: await _resolveAlternatives(plan),
        elapsed: DateTime.now().difference(session.startedAt),
      ),
    );

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const TickSecond());
    });
  }

  void _onTick(TickSecond intent, Emitter<SessionState> emit) {
    final session = state.session;
    if (session == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(session.startedAt);
    final rest = state.rest;

    if (rest == null || rest.isDone) {
      emit(state.copyWith(elapsed: elapsed));
      return;
    }

    final next = rest.tick(now);
    emit(state.copyWith(elapsed: elapsed, rest: next));

    // Only celebrate a rest that ended just now. Coming back to the app long
    // after it lapsed should not fire a stale buzz — the scheduled
    // notification already did that job.
    if (next.isDone && now.difference(rest.endsAt).inSeconds <= 3) {
      emitEffect(const RestFinished());
    }
  }

  Future<void> _onCompleteSet(
    CompleteCurrentSet intent,
    Emitter<SessionState> emit,
  ) async {
    final planned = state.currentSet;
    final session = state.session;
    if (planned == null || session == null) return;

    await _writeElapsedRest();

    final exercise = state.exerciseFor(planned);
    final log = SetLog(
      id: SetLog.unsavedId,
      sessionId: session.id,
      routineItemId: planned.item.id,
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      bodyPart: exercise.bodyPart,
      blockLabel: planned.blockLabel,
      itemOrder: planned.itemOrder,
      setIndex: planned.setIndex,
      weight: intent.weight,
      reps: intent.reps,
      durationSeconds: intent.durationSeconds,
      rir: intent.rir,
      completedAt: DateTime.now(),
    );

    final result = await _logSet(log);
    switch (result) {
      case Ok(:final value):
        _lastLogId = value;
      case Err(:final failure):
        emitEffect(ShowSessionMessage(failure.message));
        return;
    }

    await _advance(emit, restSeconds: planned.restAfterSeconds);
  }

  Future<void> _onSkipSet(
    SkipCurrentSet intent,
    Emitter<SessionState> emit,
  ) async {
    final planned = state.currentSet;
    final session = state.session;
    if (planned == null || session == null) return;

    final exercise = state.exerciseFor(planned);
    await _logSet(
      SetLog(
        id: SetLog.unsavedId,
        sessionId: session.id,
        routineItemId: planned.item.id,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        bodyPart: exercise.bodyPart,
        blockLabel: planned.blockLabel,
        itemOrder: planned.itemOrder,
        setIndex: planned.setIndex,
        isCompleted: false,
        completedAt: DateTime.now(),
      ),
    );

    _lastLogId = null;
    await _advance(emit, restSeconds: 0);
  }

  /// Cut rule — everything left in [blockIndex] is dropped without logging.
  Future<void> _onSkipBlock(
    SkipBlock intent,
    Emitter<SessionState> emit,
  ) async {
    var index = state.currentIndex;
    while (index < state.plan.length &&
        state.plan[index].blockIndex == intent.blockIndex) {
      index++;
    }

    final session = (await _getSession(sessionId)).valueOrNull;
    emit(
      state.copyWith(
        session: session,
        currentIndex: index,
        skippedBlocks: {...state.skippedBlocks, intent.blockIndex},
        clearRest: true,
      ),
    );
    _restStartedAt = null;
    await _restNotifier.cancel();
  }

  Future<void> _onJumpToSet(
    JumpToSet intent,
    Emitter<SessionState> emit,
  ) async {
    if (intent.index < 0 || intent.index > state.plan.length) return;
    emit(state.copyWith(currentIndex: intent.index, clearRest: true));
    _restStartedAt = null;
    await _restNotifier.cancel();
  }

  void _onSubstitute(SubstituteExercise intent, Emitter<SessionState> emit) {
    emit(
      state.copyWith(
        substitutions: {
          ...state.substitutions,
          intent.routineItemId: intent.exercise,
        },
      ),
    );
    emitEffect(ShowSessionMessage('${intent.exercise.name}(으)로 대체했습니다.'));
  }

  Future<void> _onAddRest(AddRest intent, Emitter<SessionState> emit) async {
    final rest = state.rest;
    if (rest == null) return;

    final extended = rest.extend(Duration(seconds: intent.seconds));
    emit(state.copyWith(rest: extended));
    await _restNotifier.scheduleRestEnd(
      endsAt: extended.endsAt,
      nextLabel: _upcomingLabel(state.currentIndex),
    );
  }

  Future<void> _onSkipRest(
    SkipRest intent,
    Emitter<SessionState> emit,
  ) async {
    await _writeElapsedRest();
    await _restNotifier.cancel();
    emit(state.copyWith(clearRest: true));
  }

  Future<void> _onEditLog(
    EditSetLog intent,
    Emitter<SessionState> emit,
  ) async {
    final result = await _updateSet(intent.log);
    if (result.isErr) {
      emitEffect(ShowSessionMessage(result.failureOrNull!.message));
      return;
    }
    await _refreshSession(emit);
  }

  Future<void> _onDeleteLog(
    DeleteSetLog intent,
    Emitter<SessionState> emit,
  ) async {
    final result = await _deleteSet(intent.setLogId);
    if (result.isErr) {
      emitEffect(ShowSessionMessage(result.failureOrNull!.message));
      return;
    }
    await _refreshSession(emit, recomputeIndex: true);
  }

  Future<void> _onFinish(
    FinishSession intent,
    Emitter<SessionState> emit,
  ) async {
    if (state.isFinishing) return;
    emit(state.copyWith(isFinishing: true));
    _ticker?.cancel();
    await _restNotifier.cancel();

    final result = await _completeSession(sessionId, memo: intent.memo);
    if (result.isErr) {
      emit(state.copyWith(isFinishing: false));
      _startTicker();
      emitEffect(ShowSessionMessage(result.failureOrNull!.message));
      return;
    }

    final suggestions = await _buildSuggestions();
    final finished = (await _getSession(sessionId)).valueOrNull ?? state.session!;
    emit(state.copyWith(isFinishing: false, session: finished));
    emitEffect(SessionCompleted(finished, suggestions));
  }

  Future<void> _onAbort(
    AbortCurrentSession intent,
    Emitter<SessionState> emit,
  ) async {
    _ticker?.cancel();
    await _restNotifier.cancel();
    final result = await _abortSession(sessionId);
    if (result.isErr) {
      _startTicker();
      emitEffect(ShowSessionMessage(result.failureOrNull!.message));
      return;
    }
    emitEffect(const SessionClosed());
  }

  // ── internals ───────────────────────────────────────────────────────────

  Future<void> _advance(
    Emitter<SessionState> emit, {
    required int restSeconds,
  }) async {
    final nextIndex = state.currentIndex + 1;
    final startRest = restSeconds > 0 && nextIndex < state.plan.length;
    final session = (await _getSession(sessionId)).valueOrNull;
    final rest = startRest ? RestState.start(restSeconds) : null;

    emit(
      state.copyWith(
        session: session,
        currentIndex: nextIndex,
        rest: rest,
        clearRest: !startRest,
      ),
    );
    _restStartedAt = startRest ? DateTime.now() : null;

    if (rest != null) {
      await _restNotifier.scheduleRestEnd(
        endsAt: rest.endsAt,
        nextLabel: _upcomingLabel(nextIndex),
      );
    } else {
      await _restNotifier.cancel();
    }
  }

  /// What the athlete does after the rest — shown on the lock screen so the
  /// notification is useful without unlocking.
  String _upcomingLabel(int index) {
    if (index >= state.plan.length) return '계획한 세트를 모두 마쳤습니다';
    final planned = state.plan[index];
    final exercise =
        state.substitutions[planned.item.id] ?? planned.item.exercise;
    return '${planned.positionLabel} · ${exercise.name}';
  }

  /// Writes how long the athlete actually rested onto the previous set's log.
  Future<void> _writeElapsedRest() async {
    final startedAt = _restStartedAt;
    final logId = _lastLogId;
    _restStartedAt = null;
    if (startedAt == null || logId == null) return;

    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    final log = state.session?.setLogs.where((l) => l.id == logId).firstOrNull;
    if (log == null) return;

    await _updateSet(log.copyWith(restSeconds: elapsed));
  }

  Future<void> _refreshSession(
    Emitter<SessionState> emit, {
    bool recomputeIndex = false,
  }) async {
    final result = await _getSession(sessionId);
    final session = result.valueOrNull;
    if (session == null) return;

    emit(
      state.copyWith(
        session: session,
        currentIndex: recomputeIndex
            ? SessionPlan.resumeIndex(state.plan, session.setLogs)
            : null,
      ),
    );
  }

  /// Resolves each item's fallback exercises once, so the substitute sheet has
  /// them ready without the widget layer touching a use case.
  Future<Map<int, List<Exercise>>> _resolveAlternatives(
    List<PlannedSet> plan,
  ) async {
    final ids = <int>{};
    for (final planned in plan) {
      ids.addAll(planned.item.alternativeExerciseIds);
    }
    if (ids.isEmpty) return const {};

    final result = await _getExercisesByIds(ids.toList());
    final byId = <int, Exercise>{
      for (final exercise in result.valueOrNull ?? const <Exercise>[])
        exercise.id: exercise,
    };

    final map = <int, List<Exercise>>{};
    for (final planned in plan) {
      final options = planned.item.alternativeExerciseIds
          .map((id) => byId[id])
          .whereType<Exercise>()
          .toList();
      if (options.isNotEmpty) map[planned.item.id] = options;
    }
    return map;
  }

  /// Double progression check for the day's weighted main movements.
  Future<List<ProgressionSuggestion>> _buildSuggestions() async {
    final seen = <int>{};
    final suggestions = <ProgressionSuggestion>[];

    for (final planned in state.plan) {
      final item = planned.item;
      if (item.repMode != RepMode.range) continue;
      if (!seen.add(item.id)) continue;

      final result = await _suggestProgression(item);
      final suggestion = result.valueOrNull;
      if (suggestion != null && suggestion.shouldIncrease) {
        suggestions.add(suggestion);
      }
    }
    return suggestions;
  }
}
