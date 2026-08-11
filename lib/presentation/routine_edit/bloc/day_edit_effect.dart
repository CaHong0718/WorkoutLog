import '../../../core/mvi/mvi_effect.dart';

sealed class DayEditEffect extends MviEffect {
  const DayEditEffect();
}

final class ShowDayEditMessage extends DayEditEffect {
  const ShowDayEditMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
