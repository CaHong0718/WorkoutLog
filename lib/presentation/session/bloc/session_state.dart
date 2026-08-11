import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/session_plan.dart';
import '../../../domain/entity/set_log.dart';
import '../../../domain/entity/workout_session.dart';

/// Rest countdown between sets or superset rounds.
class RestState extends Equatable {
  const RestState({required this.totalSeconds, required this.remainingSeconds});

  final int totalSeconds;
  final int remainingSeconds;

  bool get isDone => remainingSeconds <= 0;

  /// 0 → just started, 1 → finished.
  double get progress => totalSeconds == 0
      ? 1
      : ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);

  RestState copyWith({int? totalSeconds, int? remainingSeconds}) => RestState(
    totalSeconds: totalSeconds ?? this.totalSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
  );

  @override
  List<Object?> get props => [totalSeconds, remainingSeconds];
}

class SessionState extends MviState {
  const SessionState({
    this.isLoading = true,
    this.isFinishing = false,
    this.failure,
    this.session,
    this.day,
    this.plan = const [],
    this.currentIndex = 0,
    this.substitutions = const {},
    this.rest,
    this.elapsed = Duration.zero,
    this.lastLogs = const {},
    this.alternatives = const {},
    this.skippedBlocks = const {},
  });

  final bool isLoading;
  final bool isFinishing;
  final Failure? failure;

  final WorkoutSession? session;
  final RoutineDay? day;

  /// The day expanded into ordered sets.
  final List<PlannedSet> plan;

  /// Position in [plan]; equals `plan.length` once everything is done.
  final int currentIndex;

  /// Session-only exercise swaps, keyed by routine item id.
  final Map<int, Exercise> substitutions;

  final RestState? rest;
  final Duration elapsed;

  /// Recent logs per exercise id, used to pre-fill weight and reps.
  final Map<int, List<SetLog>> lastLogs;

  /// Predefined fallbacks per routine item id, resolved at load time.
  final Map<int, List<Exercise>> alternatives;

  /// Blocks dropped by the cut rule.
  final Set<int> skippedBlocks;

  bool get isReady => session != null && day != null && plan.isNotEmpty;

  bool get isFinished => currentIndex >= plan.length;

  PlannedSet? get currentSet =>
      isFinished || plan.isEmpty ? null : plan[currentIndex];

  PlannedSet? get nextSet =>
      currentIndex + 1 < plan.length ? plan[currentIndex + 1] : null;

  bool get isResting => rest != null && !rest!.isDone;

  int get completedSets =>
      session?.setLogs.where((l) => l.isCompleted).length ?? 0;

  int get plannedSets => plan.length;

  double get progress =>
      plan.isEmpty ? 0 : (currentIndex / plan.length).clamp(0.0, 1.0);

  /// Target session length in minutes, from the routine day's block budget.
  int get targetMinutes => day?.estimatedMinutes ?? 40;

  /// The exercise to display for [item], honouring a session substitution.
  Exercise exerciseFor(PlannedSet planned) =>
      substitutions[planned.item.id] ?? planned.item.exercise;

  /// Logs already recorded for a planned set, if any.
  SetLog? logFor(PlannedSet planned) => session?.setLogs
      .where(
        (l) =>
            l.routineItemId == planned.item.id &&
            l.setIndex == planned.setIndex,
      )
      .firstOrNull;

  SessionState copyWith({
    bool? isLoading,
    bool? isFinishing,
    Failure? failure,
    WorkoutSession? session,
    RoutineDay? day,
    List<PlannedSet>? plan,
    int? currentIndex,
    Map<int, Exercise>? substitutions,
    RestState? rest,
    Duration? elapsed,
    Map<int, List<SetLog>>? lastLogs,
    Map<int, List<Exercise>>? alternatives,
    Set<int>? skippedBlocks,
    bool clearFailure = false,
    bool clearRest = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      isFinishing: isFinishing ?? this.isFinishing,
      failure: clearFailure ? null : (failure ?? this.failure),
      session: session ?? this.session,
      day: day ?? this.day,
      plan: plan ?? this.plan,
      currentIndex: currentIndex ?? this.currentIndex,
      substitutions: substitutions ?? this.substitutions,
      rest: clearRest ? null : (rest ?? this.rest),
      elapsed: elapsed ?? this.elapsed,
      lastLogs: lastLogs ?? this.lastLogs,
      alternatives: alternatives ?? this.alternatives,
      skippedBlocks: skippedBlocks ?? this.skippedBlocks,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isFinishing,
    failure,
    session,
    day,
    plan,
    currentIndex,
    substitutions,
    rest,
    elapsed,
    lastLogs,
    alternatives,
    skippedBlocks,
  ];
}
