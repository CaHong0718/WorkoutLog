import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/routine.dart';
import '../entity/routine_block.dart';
import '../entity/routine_day.dart';
import '../entity/routine_item.dart';
import '../entity/routine_package.dart';
import '../repository/routine_exchange.dart';
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

// ── routine library ────────────────────────────────────────────────────────

@injectable
class GetRoutines {
  const GetRoutines(this._repository);

  final RoutineRepository _repository;

  Future<Result<List<Routine>>> call() => _repository.getRoutines();
}

@injectable
class WatchRoutines {
  const WatchRoutines(this._repository);

  final RoutineRepository _repository;

  Stream<List<Routine>> call() => _repository.watchRoutines();
}

/// Watches a routine that is not necessarily the active one, so a new program
/// can be built without interrupting the one in use.
@injectable
class WatchRoutine {
  const WatchRoutine(this._repository);

  final RoutineRepository _repository;

  Stream<Routine> call(int routineId) => _repository.watchRoutine(routineId);
}

@injectable
class CreateRoutine {
  const CreateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<int>> call(Routine routine) =>
      _repository.createRoutine(routine);
}

@injectable
class UpdateRoutine {
  const UpdateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(Routine routine) =>
      _repository.updateRoutine(routine);
}

@injectable
class DeleteRoutine {
  const DeleteRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int routineId) =>
      _repository.deleteRoutine(routineId);
}

@injectable
class SetActiveRoutine {
  const SetActiveRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<void>> call(int routineId) =>
      _repository.setActiveRoutine(routineId);
}

@injectable
class DuplicateRoutine {
  const DuplicateRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<int>> call(int routineId) =>
      _repository.duplicateRoutine(routineId);
}

// ── exchange ───────────────────────────────────────────────────────────────

/// Reads an exchange file into a package. Nothing is written yet — the import
/// preview runs on the result so the user sees what they are about to add.
@injectable
class ParseRoutineFile {
  const ParseRoutineFile(this._exchange);

  final RoutineExchange _exchange;

  Result<RoutineParseResult> call(String source) => _exchange.decode(source);
}

@injectable
class ImportRoutine {
  const ImportRoutine(this._repository);

  final RoutineRepository _repository;

  Future<Result<RoutineImportReport>> call(
    RoutinePackage package, {
    bool activate = false,
  }) => _repository.importRoutine(package, activate: activate);
}

/// Serializes a routine for sharing. Returns the file name alongside the body
/// so the caller does not have to reconstruct it.
@injectable
class ExportRoutine {
  const ExportRoutine(this._repository, this._exchange);

  final RoutineRepository _repository;
  final RoutineExchange _exchange;

  Future<Result<RoutineExportFile>> call(int routineId, {DateTime? now}) async {
    final result = await _repository.exportRoutine(routineId);
    return result.map((package) {
      final stamp = now ?? DateTime.now();
      return RoutineExportFile(
        fileName: _exchange.fileNameFor(package, stamp),
        contents: _exchange.encode(package, exportedAt: stamp),
      );
    });
  }
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
