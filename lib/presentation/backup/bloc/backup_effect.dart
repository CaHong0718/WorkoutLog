import '../../../core/error/failure.dart';
import '../../../core/mvi/mvi_effect.dart';
import '../../../domain/entity/backup_package.dart';

sealed class BackupEffect extends MviEffect {
  const BackupEffect();
}

final class ShowBackupMessage extends BackupEffect {
  const ShowBackupMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A file parsed cleanly. The view shows what it contains and asks how to
/// apply it before anything is written.
final class ShowRestorePreview extends BackupEffect {
  const ShowRestorePreview(this.parsed, {this.fileName});

  final BackupParseResult parsed;
  final String? fileName;

  @override
  List<Object?> get props => [parsed, fileName];
}

/// The file could not be read. Carries every problem so the view can list
/// them, each with its path inside the document.
final class ShowRestoreErrors extends BackupEffect {
  const ShowRestoreErrors(this.failure, {this.fileName});

  final RoutineFormatFailure failure;
  final String? fileName;

  @override
  List<Object?> get props => [failure, fileName];
}
