import '../../../core/mvi/mvi_effect.dart';

sealed class HomeEffect extends MviEffect {
  const HomeEffect();
}

final class OpenSession extends HomeEffect {
  const OpenSession(this.sessionId);

  final int sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class ShowHomeMessage extends HomeEffect {
  const ShowHomeMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
