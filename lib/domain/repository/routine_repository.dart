import '../../core/result/result.dart';
import '../entity/routine.dart';
import '../entity/routine_block.dart';
import '../entity/routine_day.dart';
import '../entity/routine_item.dart';
import '../entity/routine_package.dart';

abstract interface class RoutineRepository {
  /// The routine currently in use, with its full day → block → item graph.
  Future<Result<Routine>> getActiveRoutine();

  Stream<Routine> watchActiveRoutine();

  /// Every routine, each with its day graph so the list can show volume.
  Future<Result<List<Routine>>> getRoutines();

  Stream<List<Routine>> watchRoutines();

  /// Watches one routine by id, so a routine that is not active can still be
  /// edited without switching to it first.
  Stream<Routine> watchRoutine(int routineId);

  /// Creates an empty routine from [routine]'s metadata. Days are ignored.
  Future<Result<int>> createRoutine(Routine routine);

  /// Updates name / description / session length only.
  Future<Result<void>> updateRoutine(Routine routine);

  /// Refuses when it is the last routine or has a live session; hands the
  /// active flag to another routine when the deleted one held it.
  Future<Result<void>> deleteRoutine(int routineId);

  /// Exactly one routine is active at a time.
  Future<Result<void>> setActiveRoutine(int routineId);

  /// Inserts a parsed exchange file as a new routine, in one transaction.
  Future<Result<RoutineImportReport>> importRoutine(
    RoutinePackage package, {
    bool activate = false,
  });

  /// The routine as an exchange package — design only, no ids and no history.
  Future<Result<RoutinePackage>> exportRoutine(int routineId);

  /// Export followed by import, under a new name. Returns the new routine id.
  Future<Result<int>> duplicateRoutine(int routineId);

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
