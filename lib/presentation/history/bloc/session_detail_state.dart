import 'package:equatable/equatable.dart';

import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_state.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/set_log.dart';
import '../../../domain/entity/workout_session.dart';

/// Every set logged for one exercise slot of a session.
class LoggedExercise extends Equatable {
  const LoggedExercise({
    required this.name,
    required this.bodyPart,
    required this.logs,
  });

  final String name;
  final BodyPart bodyPart;
  final List<SetLog> logs;

  int get completedSets => logs.where((log) => log.isCompleted).length;

  double get volume =>
      logs.where((log) => log.isCompleted).fold(0, (sum, l) => sum + l.volume);

  @override
  List<Object?> get props => [name, bodyPart, logs];
}

/// One block of the session as it was actually performed. Built from the
/// snapshot columns of the logs, never from the current routine.
class LoggedBlock extends Equatable {
  const LoggedBlock({required this.label, required this.exercises});

  final String label;
  final List<LoggedExercise> exercises;

  int get completedSets => exercises.fold(0, (sum, e) => sum + e.completedSets);

  double get volume => exercises.fold(0, (sum, e) => sum + e.volume);

  @override
  List<Object?> get props => [label, exercises];
}

class SessionDetailState extends MviState {
  const SessionDetailState({
    this.isLoading = true,
    this.isDeleting = false,
    this.failure,
    this.session,
  });

  final bool isLoading;

  /// True while the record is being removed — blocks a second delete tap.
  final bool isDeleting;

  final Failure? failure;
  final WorkoutSession? session;

  bool get hasSession => session != null;

  /// Logs regrouped as `block → exercise → sets`, in performance order.
  List<LoggedBlock> get blocks {
    final loaded = session;
    if (loaded == null) return const [];

    final order = <String>[];
    final byBlock = <String, Map<int, List<SetLog>>>{};

    for (final log in loaded.setLogs) {
      var slots = byBlock[log.blockLabel];
      if (slots == null) {
        order.add(log.blockLabel);
        slots = <int, List<SetLog>>{};
        byBlock[log.blockLabel] = slots;
      }
      slots.putIfAbsent(log.itemOrder, () => <SetLog>[]).add(log);
    }

    final result = <LoggedBlock>[];
    for (final label in order) {
      final slots = byBlock[label]!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      result.add(
        LoggedBlock(
          label: label,
          exercises: [
            for (final slot in slots)
              LoggedExercise(
                name: slot.value.first.exerciseName,
                bodyPart: slot.value.first.bodyPart,
                logs: slot.value
                  ..sort((a, b) => a.setIndex.compareTo(b.setIndex)),
              ),
          ],
        ),
      );
    }
    return result;
  }

  SessionDetailState copyWith({
    bool? isLoading,
    bool? isDeleting,
    Failure? failure,
    WorkoutSession? session,
    bool clearFailure = false,
  }) {
    return SessionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      failure: clearFailure ? null : (failure ?? this.failure),
      session: session ?? this.session,
    );
  }

  @override
  List<Object?> get props => [isLoading, isDeleting, failure, session];
}
