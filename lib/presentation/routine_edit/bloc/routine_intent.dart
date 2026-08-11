import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/routine_day.dart';

sealed class RoutineIntent extends MviIntent {
  const RoutineIntent();
}

/// Subscribes to one routine; every later edit arrives through the same
/// stream, so the overview never shows a stale set count.
///
/// [routineId] null means "whichever routine is active" — the routine tab.
/// A concrete id lets a routine be edited without switching to it first.
final class LoadRoutine extends RoutineIntent {
  const LoadRoutine({this.routineId});

  final int? routineId;

  @override
  List<Object?> get props => [routineId];
}

/// Appends [day] to the routine and opens its editor.
final class CreateDay extends RoutineIntent {
  const CreateDay(this.day);

  final RoutineDay day;

  @override
  List<Object?> get props => [day];
}

final class RemoveDay extends RoutineIntent {
  const RemoveDay(this.dayId);

  final int dayId;

  @override
  List<Object?> get props => [dayId];
}

/// Drag result from `ReorderableListView.onReorderItem`, which already
/// normalises [newIndex] for the removed item.
final class MoveDay extends RoutineIntent {
  const MoveDay({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
