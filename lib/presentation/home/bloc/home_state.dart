import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/workout_session.dart';

class HomeState extends MviState {
  const HomeState({
    this.isLoading = true,
    this.isStarting = false,
    this.failure,
    this.routine,
    this.selectedDay,
    this.pinnedDayId,
    this.inProgressSession,
    this.weeklyVolume = const {},
  });

  final bool isLoading;

  /// True while a session is being created — disables the start button.
  final bool isStarting;

  final Failure? failure;

  final Routine? routine;

  /// The day that will be trained: rotation default, or the user's override.
  final RoutineDay? selectedDay;

  /// Set only when the user picked a day by hand. It survives refreshes but is
  /// dropped once a workout starts, so rotation takes over again afterwards —
  /// otherwise finishing DAY A would leave DAY A on the card forever.
  final int? pinnedDayId;

  final WorkoutSession? inProgressSession;

  /// Completed sets per body part so far this week.
  final Map<BodyPart, int> weeklyVolume;

  bool get hasRoutine => routine != null && selectedDay != null;

  bool get hasInProgress => inProgressSession != null;

  /// Weekly target per body part, derived from the routine itself.
  Map<BodyPart, int> get weeklyTarget =>
      routine?.weeklyVolumeByBodyPart ?? const {};

  int get weeklyCompletedSets =>
      weeklyVolume.values.fold(0, (sum, v) => sum + v);

  int get weeklyTargetSets => routine?.weeklySets ?? 0;

  HomeState copyWith({
    bool? isLoading,
    bool? isStarting,
    Failure? failure,
    Routine? routine,
    RoutineDay? selectedDay,
    int? pinnedDayId,
    WorkoutSession? inProgressSession,
    Map<BodyPart, int>? weeklyVolume,
    bool clearFailure = false,
    bool clearInProgress = false,
    bool clearPinnedDay = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      failure: clearFailure ? null : (failure ?? this.failure),
      routine: routine ?? this.routine,
      selectedDay: selectedDay ?? this.selectedDay,
      pinnedDayId: clearPinnedDay ? null : (pinnedDayId ?? this.pinnedDayId),
      inProgressSession: clearInProgress
          ? null
          : (inProgressSession ?? this.inProgressSession),
      weeklyVolume: weeklyVolume ?? this.weeklyVolume,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isStarting,
    failure,
    routine,
    selectedDay,
    pinnedDayId,
    inProgressSession,
    weeklyVolume,
  ];
}
