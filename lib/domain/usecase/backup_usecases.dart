import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/backup_package.dart';
import '../repository/backup_exchange.dart';
import '../repository/backup_repository.dart';

/// What the database holds right now — the numbers on the backup screen.
@injectable
class GetBackupSummary {
  const GetBackupSummary(this._repository);

  final BackupRepository _repository;

  Future<Result<BackupSummary>> call() => _repository.summarize();
}

/// Reads a backup file into a package. Nothing is written yet — the restore
/// preview runs on the result so the user sees what they are about to take on.
@injectable
class ParseBackupFile {
  const ParseBackupFile(this._exchange);

  final BackupExchange _exchange;

  Result<BackupParseResult> call(String source) => _exchange.decode(source);
}

/// Serializes the whole database for sharing. Returns the file name alongside
/// the body so the caller does not have to reconstruct it.
@injectable
class ExportBackup {
  const ExportBackup(this._repository, this._exchange);

  final BackupRepository _repository;
  final BackupExchange _exchange;

  Future<Result<BackupExportFile>> call({DateTime? now}) async {
    final result = await _repository.exportBackup();
    return result.map((package) {
      final stamp = now ?? DateTime.now();
      return BackupExportFile(
        fileName: _exchange.fileNameFor(stamp),
        contents: _exchange.encode(package, exportedAt: stamp),
      );
    });
  }
}

/// The user confirmed the preview and picked a mode.
@injectable
class ImportBackup {
  const ImportBackup(this._repository);

  final BackupRepository _repository;

  Future<Result<BackupImportReport>> call(
    BackupPackage package, {
    required BackupRestoreMode mode,
  }) => _repository.importBackup(package, mode: mode);
}
