import '../../../core/mvi/mvi_intent.dart';
import '../../../domain/entity/exercise.dart';
import '../../../domain/entity/routine_block.dart';
import '../../../domain/entity/routine_day.dart';
import '../../../domain/entity/routine_item.dart';

sealed class DayEditIntent extends MviIntent {
  const DayEditIntent();
}

/// Loads the day graph plus the exercise library used by the pickers.
final class LoadDay extends DayEditIntent {
  const LoadDay();
}

/// Code / title / subtitle / description / main body part.
final class SaveDayMeta extends DayEditIntent {
  const SaveDayMeta(this.day);

  final RoutineDay day;

  @override
  List<Object?> get props => [day];
}

/// Appends a block with sensible defaults.
final class CreateBlock extends DayEditIntent {
  const CreateBlock();
}

/// Writes an edited block. When it became a superset the items' set counts
/// follow the round count.
final class SaveBlock extends DayEditIntent {
  const SaveBlock(this.block);

  final RoutineBlock block;

  @override
  List<Object?> get props => [block];
}

final class RemoveBlock extends DayEditIntent {
  const RemoveBlock(this.blockId);

  final int blockId;

  @override
  List<Object?> get props => [blockId];
}

/// Indices as delivered by `ReorderableListView.onReorderItem`.
final class MoveBlock extends DayEditIntent {
  const MoveBlock({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Adds [exercise] to the block as a new slot at the end.
final class CreateItem extends DayEditIntent {
  const CreateItem({required this.blockId, required this.exercise});

  final int blockId;
  final Exercise exercise;

  @override
  List<Object?> get props => [blockId, exercise];
}

final class SaveItem extends DayEditIntent {
  const SaveItem(this.item);

  final RoutineItem item;

  @override
  List<Object?> get props => [item];
}

final class RemoveItem extends DayEditIntent {
  const RemoveItem(this.itemId);

  final int itemId;

  @override
  List<Object?> get props => [itemId];
}

final class MoveItem extends DayEditIntent {
  const MoveItem({
    required this.blockId,
    required this.oldIndex,
    required this.newIndex,
  });

  final int blockId;
  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [blockId, oldIndex, newIndex];
}
