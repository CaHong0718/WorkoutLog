import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/set_log.dart';

sealed class SessionIntent extends MviIntent {
  const SessionIntent();
}

final class LoadSession extends SessionIntent {
  const LoadSession();
}

/// One-second heartbeat driving the elapsed clock and the rest countdown.
final class TickSecond extends SessionIntent {
  const TickSecond();
}

/// Logs the current planned set and advances.
final class CompleteCurrentSet extends SessionIntent {
  const CompleteCurrentSet({
    this.weight,
    this.reps,
    this.rir,
    this.durationSeconds,
  });

  final double? weight;
  final int? reps;
  final int? rir;
  final int? durationSeconds;

  @override
  List<Object?> get props => [weight, reps, rir, durationSeconds];
}

/// Records the set as not performed and advances.
final class SkipCurrentSet extends SessionIntent {
  const SkipCurrentSet();
}

/// Cut rule: drops every remaining set of a block.
final class SkipBlock extends SessionIntent {
  const SkipBlock(this.blockIndex);

  final int blockIndex;

  @override
  List<Object?> get props => [blockIndex];
}

final class JumpToSet extends SessionIntent {
  const JumpToSet(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Swaps the exercise for this session only — the routine is untouched.
final class SubstituteExercise extends SessionIntent {
  const SubstituteExercise(this.routineItemId, this.exercise);

  final int routineItemId;
  final Exercise exercise;

  @override
  List<Object?> get props => [routineItemId, exercise];
}

final class AddRest extends SessionIntent {
  const AddRest(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

final class SkipRest extends SessionIntent {
  const SkipRest();
}

final class EditSetLog extends SessionIntent {
  const EditSetLog(this.log);

  final SetLog log;

  @override
  List<Object?> get props => [log];
}

final class DeleteSetLog extends SessionIntent {
  const DeleteSetLog(this.setLogId);

  final int setLogId;

  @override
  List<Object?> get props => [setLogId];
}

final class FinishSession extends SessionIntent {
  const FinishSession({this.memo});

  final String? memo;

  @override
  List<Object?> get props => [memo];
}

final class AbortCurrentSession extends SessionIntent {
  const AbortCurrentSession();
}
