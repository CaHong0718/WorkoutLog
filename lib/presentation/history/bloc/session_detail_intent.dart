import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/set_log.dart';

sealed class SessionDetailIntent extends MviIntent {
  const SessionDetailIntent();
}

/// Initial load and pull-to-refresh of one recorded session.
final class LoadSessionDetail extends SessionDetailIntent {
  const LoadSessionDetail();
}

/// Permanently removes this record. Confirmed by the page beforehand.
final class DeleteSessionRecord extends SessionDetailIntent {
  const DeleteSessionRecord();
}

/// Rewrites one recorded set — a mistyped weight or rep count, or a set that
/// should not have counted. The record itself stays.
final class UpdateLoggedSet extends SessionDetailIntent {
  const UpdateLoggedSet(this.log);

  final SetLog log;

  @override
  List<Object?> get props => [log];
}

/// Removes a single set from the record. Confirmed by the sheet beforehand.
final class DeleteLoggedSet extends SessionDetailIntent {
  const DeleteLoggedSet(this.setLogId);

  final int setLogId;

  @override
  List<Object?> get props => [setLogId];
}
