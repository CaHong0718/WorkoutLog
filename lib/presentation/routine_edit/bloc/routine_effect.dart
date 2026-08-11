import '../../../core/mvi/mvi_effect.dart';

sealed class RoutineEffect extends MviEffect {
  const RoutineEffect();
}

/// A day was created — the page pushes its editor.
final class OpenDayEditor extends RoutineEffect {
  const OpenDayEditor(this.dayId);

  final int dayId;

  @override
  List<Object?> get props => [dayId];
}

final class ShowRoutineMessage extends RoutineEffect {
  const ShowRoutineMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
