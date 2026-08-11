import '../../core/result/result.dart';
import '../entity/routine.dart';
import '../entity/routine_block.dart';
import '../entity/routine_day.dart';
import '../entity/routine_item.dart';

abstract interface class RoutineRepository {
  /// The routine currently in use, with its full day → block → item graph.
  Future<Result<Routine>> getActiveRoutine();

  Stream<Routine> watchActiveRoutine();

  Future<Result<List<RoutineDay>>> getDays(int routineId);

  Future<Result<RoutineDay>> getDayDetail(int dayId);

  /// Next day in the A → B → C → D rotation, based on the last completed
  /// session. Falls back to the first day when there is no history.
  Future<Result<RoutineDay>> getNextDay();

  /// Inserts when [RoutineDay.id] is [RoutineDay.unsavedId], updates otherwise.
  /// Returns the row id.
  Future<Result<int>> upsertDay(RoutineDay day);

  Future<Result<void>> deleteDay(int dayId);

  Future<Result<void>> reorderDays(int routineId, List<int> orderedDayIds);

  Future<Result<int>> upsertBlock(RoutineBlock block);

  Future<Result<void>> deleteBlock(int blockId);

  Future<Result<void>> reorderBlocks(int dayId, List<int> orderedBlockIds);

  Future<Result<int>> upsertItem(RoutineItem item);

  Future<Result<void>> deleteItem(int itemId);

  Future<Result<void>> reorderItems(int blockId, List<int> orderedItemIds);
}
