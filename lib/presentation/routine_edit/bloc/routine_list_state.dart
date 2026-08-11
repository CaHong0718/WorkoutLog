import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/routine.dart';

class RoutineListState extends MviState {
  const RoutineListState({
    this.isLoading = true,
    this.isBusy = false,
    this.failure,
    this.routines = const [],
  });

  final bool isLoading;

  /// True while a write or a platform dialog is in flight — the card actions
  /// disable so a double tap cannot import the same file twice.
  final bool isBusy;

  final Failure? failure;

  final List<Routine> routines;

  bool get isEmpty => routines.isEmpty;

  Routine? get active {
    for (final routine in routines) {
      if (routine.isActive) return routine;
    }
    return null;
  }

  /// Deleting the only routine would leave the home screen with nothing to
  /// show, so the action is hidden rather than failing on tap.
  bool get canDelete => routines.length > 1;

  RoutineListState copyWith({
    bool? isLoading,
    bool? isBusy,
    Failure? failure,
    List<Routine>? routines,
    bool clearFailure = false,
  }) {
    return RoutineListState(
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      failure: clearFailure ? null : (failure ?? this.failure),
      routines: routines ?? this.routines,
    );
  }

  @override
  List<Object?> get props => [isLoading, isBusy, failure, routines];
}
