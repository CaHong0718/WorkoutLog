import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/routine.dart';
import '../../../domain/entity/routine_package.dart';

sealed class RoutineListIntent extends MviIntent {
  const RoutineListIntent();
}

/// Subscribes to every routine; later edits arrive through the same stream.
final class LoadRoutines extends RoutineListIntent {
  const LoadRoutines();
}

/// Makes one routine the one the home screen and workouts use.
final class ActivateRoutine extends RoutineListIntent {
  const ActivateRoutine(this.routineId);

  final int routineId;

  @override
  List<Object?> get props => [routineId];
}

/// Creates when [routine] carries [Routine.unsavedId], updates otherwise.
final class SaveRoutineMeta extends RoutineListIntent {
  const SaveRoutineMeta(this.routine);

  final Routine routine;

  @override
  List<Object?> get props => [routine];
}

final class RemoveRoutine extends RoutineListIntent {
  const RemoveRoutine(this.routineId);

  final int routineId;

  @override
  List<Object?> get props => [routineId];
}

final class CopyRoutine extends RoutineListIntent {
  const CopyRoutine(this.routineId);

  final int routineId;

  @override
  List<Object?> get props => [routineId];
}

/// Opens the system file picker. The parsed result goes back to the view as a
/// preview effect — nothing is written until the user confirms.
final class PickRoutineFile extends RoutineListIntent {
  const PickRoutineFile();
}

/// Parses text that arrived from anywhere (picker, share from another app).
final class ReadRoutineSource extends RoutineListIntent {
  const ReadRoutineSource(this.contents, {this.fileName});

  final String contents;
  final String? fileName;

  @override
  List<Object?> get props => [contents, fileName];
}

/// The user confirmed the preview.
final class ConfirmImport extends RoutineListIntent {
  const ConfirmImport(this.package, {this.activate = false});

  final RoutinePackage package;
  final bool activate;

  @override
  List<Object?> get props => [package, activate];
}

/// Serializes a routine and hands it to the share sheet.
final class ShareRoutine extends RoutineListIntent {
  const ShareRoutine(this.routineId);

  final int routineId;

  @override
  List<Object?> get props => [routineId];
}
