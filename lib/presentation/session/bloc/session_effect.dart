import '../../../core/mvi/mvi_effect.dart';
import '../../../domain/entity/progression_suggestion.dart';
import '../../../domain/entity/workout_session.dart';

sealed class SessionEffect extends MviEffect {
  const SessionEffect();
}

/// Rest countdown hit zero — the page fires haptic feedback.
final class RestFinished extends SessionEffect {
  const RestFinished();
}

/// The session was completed; the page shows the summary then leaves.
final class SessionCompleted extends SessionEffect {
  const SessionCompleted(this.session, this.suggestions);

  final WorkoutSession session;
  final List<ProgressionSuggestion> suggestions;

  @override
  List<Object?> get props => [session, suggestions];
}

final class SessionClosed extends SessionEffect {
  const SessionClosed();
}

final class ShowSessionMessage extends SessionEffect {
  const ShowSessionMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
