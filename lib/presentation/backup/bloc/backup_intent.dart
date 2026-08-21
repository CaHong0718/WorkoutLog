import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/backup_package.dart';

sealed class BackupIntent extends MviIntent {
  const BackupIntent();
}

/// Counts what the database holds, so the screen can say what is at stake.
final class LoadBackupSummary extends BackupIntent {
  const LoadBackupSummary();
}

/// Serializes everything and hands it to the share sheet.
final class ShareBackupFile extends BackupIntent {
  const ShareBackupFile();
}

/// Opens the system file picker. The parsed result goes back to the view as a
/// preview effect — nothing is written until the user confirms.
final class PickBackupFile extends BackupIntent {
  const PickBackupFile();
}

/// Parses text that arrived from anywhere (picker, share from another app).
final class ReadBackupSource extends BackupIntent {
  const ReadBackupSource(this.contents, {this.fileName});

  final String contents;
  final String? fileName;

  @override
  List<Object?> get props => [contents, fileName];
}

/// The user saw the preview and picked a mode.
final class ConfirmRestore extends BackupIntent {
  const ConfirmRestore(this.package, {required this.mode});

  final BackupPackage package;
  final BackupRestoreMode mode;

  @override
  List<Object?> get props => [package, mode];
}
