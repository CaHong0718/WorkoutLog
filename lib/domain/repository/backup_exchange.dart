import '../../core/result/result.dart';
import '../entity/backup_package.dart';

/// Reads and writes the backup format (`docs/07-BACKUP.md`).
///
/// A port rather than a plain utility so the domain can depend on it: the
/// implementation lives in `data/exchange/backup_codec.dart`.
abstract interface class BackupExchange {
  /// The `format` field every backup file carries. Lives on the port so a
  /// caller can tell a shared file apart without reaching into the codec.
  static const String formatId = 'workout-log.backup';

  /// Parses a backup document.
  ///
  /// Fails with `RoutineFormatFailure` carrying every problem found — the same
  /// type the routine reader uses, because the restore screen lists them the
  /// same way and a backup embeds routines verbatim.
  Result<BackupParseResult> decode(String source);

  /// Serializes [package] as pretty-printed JSON, ready to be written to a
  /// file.
  String encode(BackupPackage package, {DateTime? exportedAt});

  /// `운동기록_20260821.json`
  String fileNameFor(DateTime now);
}
