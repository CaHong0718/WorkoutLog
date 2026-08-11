import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_effect.dart';
import '../../../domain/entity/routine_package.dart';

sealed class RoutineListEffect extends MviEffect {
  const RoutineListEffect();
}

final class ShowRoutineListMessage extends RoutineListEffect {
  const ShowRoutineListMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A file parsed cleanly. The view shows what it contains and asks before
/// anything is written.
final class ShowImportPreview extends RoutineListEffect {
  const ShowImportPreview(this.parsed, {this.fileName});

  final RoutineParseResult parsed;
  final String? fileName;

  @override
  List<Object?> get props => [parsed, fileName];
}

/// The file could not be read. Carries every problem so the view can list
/// them, each with its path inside the document.
final class ShowImportErrors extends RoutineListEffect {
  const ShowImportErrors(this.failure, {this.fileName});

  final RoutineFormatFailure failure;
  final String? fileName;

  @override
  List<Object?> get props => [failure, fileName];
}

/// A routine was created or imported — open its day editor.
final class OpenRoutineEditor extends RoutineListEffect {
  const OpenRoutineEditor(this.routineId);

  final int routineId;

  @override
  List<Object?> get props => [routineId];
}
