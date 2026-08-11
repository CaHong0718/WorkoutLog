import '../../../core/mvi/mvi_effect.dart';

sealed class StatsEffect extends MviEffect {
  const StatsEffect();
}

final class ShowStatsMessage extends StatsEffect {
  const ShowStatsMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
