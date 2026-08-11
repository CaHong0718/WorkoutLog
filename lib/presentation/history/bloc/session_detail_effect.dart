import '../../../core/mvi/mvi_effect.dart';

sealed class SessionDetailEffect extends MviEffect {
  const SessionDetailEffect();
}

/// The record is gone — the page closes and the caller refreshes.
final class SessionRecordDeleted extends SessionDetailEffect {
  const SessionRecordDeleted();
}

final class ShowSessionDetailMessage extends SessionDetailEffect {
  const ShowSessionDetailMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
