import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/exercise_progress_point.dart';

/// An exercise that actually appears in the history, built from set log
/// snapshots so a renamed or deleted exercise still charts correctly.
class TrendExercise extends Equatable {
  const TrendExercise({
    required this.id,
    required this.name,
    required this.bodyPart,
  });

  final int id;
  final String name;
  final BodyPart bodyPart;

  @override
  List<Object?> get props => [id, name, bodyPart];
}

/// Volume + trend tabs. One state object covers both: they share the routine
/// target and are always loaded together.
class StatsState extends MviState {
  const StatsState({
    required this.weekStart,
    this.isLoading = true,
    this.hasLoaded = false,
    this.isWeekLoading = false,
    this.isTrendLoading = false,
    this.failure,
    this.weeklyVolume = const {},
    this.targetVolume = const {},
    this.targetSets = 0,
    this.trendExercises = const [],
    this.selectedExerciseId,
    this.progress = const [],
  });

  factory StatsState.initial() =>
      StatsState(weekStart: DateTime.now().startOfWeek);

  final bool isLoading;

  /// True once the first load finished — separates "empty" from "not yet".
  final bool hasLoaded;

  /// True while another week is being fetched — keeps the bars on screen.
  final bool isWeekLoading;

  final bool isTrendLoading;

  final Failure? failure;

  /// Monday of the week the volume chart is showing.
  final DateTime weekStart;

  /// Completed sets per body part inside that week.
  final Map<BodyPart, int> weeklyVolume;

  /// The routine's own weekly plan (`02-ROUTINE-SEED.md` §6).
  final Map<BodyPart, int> targetVolume;

  /// Sets over one full rotation — 70 for the seeded routine.
  final int targetSets;

  final List<TrendExercise> trendExercises;

  final int? selectedExerciseId;

  final List<ExerciseProgressPoint> progress;

  DateTime get weekEnd => weekStart.endOfWeek;

  bool get isCurrentWeek => weekStart == DateTime.now().startOfWeek;

  int get completedSets => weeklyVolume.values.fold(0, (sum, v) => sum + v);

  /// Body parts to draw, planned ones first and by descending target.
  List<BodyPart> get volumeParts {
    final parts = {...targetVolume.keys, ...weeklyVolume.keys}.toList()
      ..sort((a, b) {
        final byTarget = (targetVolume[b] ?? 0).compareTo(targetVolume[a] ?? 0);
        return byTarget != 0 ? byTarget : a.index.compareTo(b.index);
      });
    return parts;
  }

  TrendExercise? get selectedExercise {
    final id = selectedExerciseId;
    if (id == null) return null;
    for (final exercise in trendExercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  /// A single point draws no line — the chart needs at least two.
  bool get hasTrend => progress.length >= 2;

  StatsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    bool? isWeekLoading,
    bool? isTrendLoading,
    Failure? failure,
    DateTime? weekStart,
    Map<BodyPart, int>? weeklyVolume,
    Map<BodyPart, int>? targetVolume,
    int? targetSets,
    List<TrendExercise>? trendExercises,
    int? selectedExerciseId,
    List<ExerciseProgressPoint>? progress,
    bool clearFailure = false,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isWeekLoading: isWeekLoading ?? this.isWeekLoading,
      isTrendLoading: isTrendLoading ?? this.isTrendLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      weekStart: weekStart ?? this.weekStart,
      weeklyVolume: weeklyVolume ?? this.weeklyVolume,
      targetVolume: targetVolume ?? this.targetVolume,
      targetSets: targetSets ?? this.targetSets,
      trendExercises: trendExercises ?? this.trendExercises,
      selectedExerciseId: selectedExerciseId ?? this.selectedExerciseId,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    hasLoaded,
    isWeekLoading,
    isTrendLoading,
    failure,
    weekStart,
    weeklyVolume,
    targetVolume,
    targetSets,
    trendExercises,
    selectedExerciseId,
    progress,
  ];
}
