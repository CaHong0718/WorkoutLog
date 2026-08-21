import '../../core/result/result.dart';
import '../entity/backup_package.dart';

abstract interface class BackupRepository {
  /// Counts for what the database holds right now, so the backup screen can
  /// say what is at stake before anything is written.
  Future<Result<BackupSummary>> summarize();

  /// The whole database as a package: library, routines, finished sessions.
  ///
  /// In-progress sessions are left out — see `docs/07-BACKUP.md` §5.
  Future<Result<BackupPackage>> exportBackup();

  /// Writes [package] back, in a **single transaction**.
  ///
  /// [BackupRestoreMode.merge] keeps everything already there and adds what is
  /// missing; [BackupRestoreMode.replace] empties every table first and is
  /// refused while a session is in progress.
  Future<Result<BackupImportReport>> importBackup(
    BackupPackage package, {
    required BackupRestoreMode mode,
  });
}
