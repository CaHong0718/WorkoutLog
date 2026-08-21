import '../../core/result/result.dart';
import '../entity/routine_package.dart';

/// Reads and writes the routine exchange format (`docs/04-ROUTINE-EXCHANGE.md`).
///
/// A port rather than a plain utility so the domain can depend on it: the
/// implementation lives in `data/exchange/routine_codec.dart`.
abstract interface class RoutineExchange {
  /// Parses an exchange document.
  ///
  /// Fails with `RoutineFormatFailure` carrying every problem found, so the
  /// import screen can list them all at once.
  Result<RoutineParseResult> decode(String source);

  /// Serializes [package] as pretty-printed JSON, ready to be written to a file.
  String encode(RoutinePackage package, {DateTime? exportedAt});

  /// `상하체 2분할_20260811.json`
  String fileNameFor(RoutinePackage package, DateTime now);

  /// The `routine` object on its own, without the file envelope.
  ///
  /// A backup file (`docs/07-BACKUP.md`) stores routines in exactly this shape,
  /// so both formats share one definition instead of drifting apart.
  Map<String, Object?> encodeRoutineBody(RoutinePackage package);

  /// Reads a bare `routine` object. [path] prefixes every problem reported, so
  /// a backup can say `routines[2].days[0]` where a routine file says
  /// `routine.days[0]`.
  RoutineBodyParse decodeRoutineBody(Object? json, {required String path});
}
