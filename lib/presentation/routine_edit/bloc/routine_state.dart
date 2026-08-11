import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine.dart';
import '../../../domain/entity/routine_day.dart';

class RoutineState extends MviState {
  const RoutineState({
    this.isLoading = true,
    this.isSaving = false,
    this.failure,
    this.routine,
  });

  final bool isLoading;

  /// True while a write is in flight — disables the editing affordances.
  final bool isSaving;

  final Failure? failure;

  final Routine? routine;

  bool get hasRoutine => routine != null;

  List<RoutineDay> get days => routine?.days ?? const [];

  /// Sets accumulated over one full rotation.
  int get weeklySets => routine?.weeklySets ?? 0;

  Map<BodyPart, int> get weeklyVolume =>
      routine?.weeklyVolumeByBodyPart ?? const {};

  RoutineState copyWith({
    bool? isLoading,
    bool? isSaving,
    Failure? failure,
    Routine? routine,
    bool clearFailure = false,
  }) {
    return RoutineState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
      routine: routine ?? this.routine,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, failure, routine];
}
