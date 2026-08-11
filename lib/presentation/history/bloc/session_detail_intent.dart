import '../../../core/mvi/mvi_intent.dart';

sealed class SessionDetailIntent extends MviIntent {
  const SessionDetailIntent();
}

/// Initial load and pull-to-refresh of one recorded session.
final class LoadSessionDetail extends SessionDetailIntent {
  const LoadSessionDetail();
}
