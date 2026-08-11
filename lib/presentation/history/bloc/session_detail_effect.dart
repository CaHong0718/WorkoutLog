import '../../../core/mvi/mvi_effect.dart';

sealed class SessionDetailEffect extends MviEffect {
  const SessionDetailEffect();
}

final class ShowSessionDetailMessage extends SessionDetailEffect {
  const ShowSessionDetailMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
