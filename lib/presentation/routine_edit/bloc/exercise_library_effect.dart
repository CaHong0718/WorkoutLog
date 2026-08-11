import '../../../core/mvi/mvi_effect.dart';

sealed class ExerciseLibraryEffect extends MviEffect {
  const ExerciseLibraryEffect();
}

final class ShowLibraryMessage extends ExerciseLibraryEffect {
  const ShowLibraryMessage(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
