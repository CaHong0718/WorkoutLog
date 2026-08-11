import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/routine.dart';
import '../entity/routine_block.dart';
import '../entity/routine_day.dart';
import '../entity/routine_item.dart';
import '../repository/routine_repository.dart';

@injectable
class GetActiveRoutine {
  const GetActiveRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<Routine>> call() => _repository.getActiveRoutine();
}

@injectable
class WatchActiveRoutine {
  const WatchActiveRoutine(this._repository);

  final RoutineRepository _repository;

  Stream<Routine> call() => _repository.watchActiveRoutine();
}

@injectable
class GetRoutineDays {
  const GetRoutineDays(this._repository);

  final RoutineRepository _repository;

  Future<Result<List<RoutineDay>>> call(int routineId) =>
      _repository.getDays(routineId);
}

@injectable
class GetDayDetail {
  const GetDayDetail(this._repository);

  final RoutineRepository _repository;

  Future<Result<RoutineDay>> call(int dayId) => _repository.getDayDetail(dayId);
}

/// Next day in the A → B → C → D rotation.
@injectable
class GetNextDay {
  const GetNextDay(this._repository);

  final RoutineRepository _repository;

  Future<Result<RoutineDay>> call() => _repository.getNextDay();
}

@injectable
class UpsertDay {
  const UpsertDay(this._repository);

  final RoutineRepository _repository;

  Future<Result<int>> call(RoutineDay day) => _repository.upsertDay(day);
}

@injectable
class DeleteDay {
  const DeleteDay(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int dayId) => _repository.deleteDay(dayId);
}

@injectable
class ReorderDays {
  const ReorderDays(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int routineId, List<int> orderedDayIds) =>
      _repository.reorderDays(routineId, orderedDayIds);
}

@injectable
class UpsertBlock {
  const UpsertBlock(this._repository);

  final RoutineRepository _repository;

  Future<Result<int>> call(RoutineBlock block) =>
      _repository.upsertBlock(block);
}

@injectable
class DeleteBlock {
  const DeleteBlock(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int blockId) => _repository.deleteBlock(blockId);
}

@injectable
class ReorderBlocks {
  const ReorderBlocks(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int dayId, List<int> orderedBlockIds) =>
      _repository.reorderBlocks(dayId, orderedBlockIds);
}

@injectable
class UpsertItem {
  const UpsertItem(this._repository);

  final RoutineRepository _repository;

  Future<Result<int>> call(RoutineItem item) => _repository.upsertItem(item);
}

@injectable
class DeleteItem {
  const DeleteItem(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int itemId) => _repository.deleteItem(itemId);
}

@injectable
class ReorderItems {
  const ReorderItems(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int blockId, List<int> orderedItemIds) =>
      _repository.reorderItems(blockId, orderedItemIds);
}
