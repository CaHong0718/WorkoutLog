import '../../../core/mvi/mvi_effect.dart';

sealed class HistoryEffect extends MviEffect {
  const HistoryEffect();
}

final class OpenSessionDetail extends HistoryEffect {
  const OpenSessionDetail(this.sessionId);

  final int sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class ShowHistoryMessage extends HistoryEffect {
  const ShowHistoryMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
