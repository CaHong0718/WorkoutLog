import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../../domain/entity/exercise.dart';
import '../../domain/entity/routine.dart';
import '../../domain/entity/routine_block.dart';
import '../../domain/entity/routine_day.dart';
import '../../domain/entity/routine_item.dart';
import '../../domain/repository/routine_repository.dart';
import '../database/app_database.dart';
import '../database/daos/routine_dao.dart';
import '../mapper/mappers.dart';
import 'data_errors.dart';

@LazySingleton(as: RoutineRepository)
class RoutineRepositoryImpl implements RoutineRepository {
  RoutineRepositoryImpl(this._dao, this._db);

  final RoutineDao _dao;
  final AppDatabase _db;

  @override
  Future<Result<Routine>> getActiveRoutine() =>
      runCatching(_loadActiveRoutine, onError: classifyFailure);

  @override
  Stream<Routine> watchActiveRoutine() async* {
    yield await _loadActiveRoutine();
    final updates = _db.tableUpdates(
      TableUpdateQuery.onAllTables(_db.routineGraphTables),
    );
    await for (final _ in updates) {
      yield await _loadActiveRoutine();
    }
  }

  @override
  Future<Result<List<RoutineDay>>> getDays(int routineId) =>
      runCatching(() async {
        final dayRows = await _dao.daysOf(routineId);
        return _assembleDays(dayRows);
      });

  @override
  Future<Result<RoutineDay>> getDayDetail(int dayId) => runCatching(() async {
    final row = await _dao.findDay(dayId);
    if (row == null) throw const NotFoundException('루틴 DAY를 찾을 수 없습니다.');
    final days = await _assembleDays([row]);
    return days.single;
  }, onError: classifyFailure);

  @override
  Future<Result<RoutineDay>> getNextDay() => runCatching(() async {
    final routineRow = await _dao.findActiveRoutine();
    if (routineRow == null) throw const NotFoundException('활성 루틴이 없습니다.');

    final dayRows = await _dao.daysOf(routineRow.id);
    if (dayRows.isEmpty) throw const NotFoundException('루틴에 DAY가 없습니다.');

    final lastSession = await _dao.lastCompletedSession(routineRow.id);
    var nextIndex = 0;
    if (lastSession != null) {
      // Prefer the id; fall back to the code snapshot if the day was deleted.
      var lastIndex = dayRows.indexWhere((d) => d.id == lastSession.dayId);
      if (lastIndex < 0) {
        lastIndex = dayRows.indexWhere((d) => d.code == lastSession.dayCode);
      }
      if (lastIndex >= 0) nextIndex = (lastIndex + 1) % dayRows.length;
    }

    final days = await _assembleDays([dayRows[nextIndex]]);
    return days.single;
  }, onError: classifyFailure);

  @override
  Future<Result<int>> upsertDay(RoutineDay day) =>
      runCatching(() => _dao.upsertDay(day.id, day.toCompanion()));

  @override
  Future<Result<void>> deleteDay(int dayId) =>
      runCatching(() => _dao.deleteDay(dayId));

  @override
  Future<Result<void>> reorderDays(int routineId, List<int> orderedDayIds) =>
      runCatching(() => _dao.reorderDays(orderedDayIds));

  @override
  Future<Result<int>> upsertBlock(RoutineBlock block) =>
      runCatching(() => _dao.upsertBlock(block.id, block.toCompanion()));

  @override
  Future<Result<void>> deleteBlock(int blockId) =>
      runCatching(() => _dao.deleteBlock(blockId));

  @override
  Future<Result<void>> reorderBlocks(int dayId, List<int> orderedBlockIds) =>
      runCatching(() => _dao.reorderBlocks(orderedBlockIds));

  @override
  Future<Result<int>> upsertItem(RoutineItem item) =>
      runCatching(() => _dao.upsertItem(item.id, item.toCompanion()));

  @override
  Future<Result<void>> deleteItem(int itemId) =>
      runCatching(() => _dao.deleteItem(itemId));

  @override
  Future<Result<void>> reorderItems(int blockId, List<int> orderedItemIds) =>
      runCatching(() => _dao.reorderItems(orderedItemIds));

  // ── internals ───────────────────────────────────────────────────────────

  Future<Routine> _loadActiveRoutine() async {
    final routineRow = await _dao.findActiveRoutine();
    if (routineRow == null) throw const NotFoundException('활성 루틴이 없습니다.');
    final dayRows = await _dao.daysOf(routineRow.id);
    return routineRow.toEntity(days: await _assembleDays(dayRows));
  }

  /// Loads blocks, items and their exercises in three batched queries rather
  /// than per-row lookups.
  Future<List<RoutineDay>> _assembleDays(List<RoutineDayRow> dayRows) async {
    if (dayRows.isEmpty) return const [];

    final blockRows = await _dao.blocksOf(dayRows.map((d) => d.id).toList());
    final itemRows = await _dao.itemsOf(blockRows.map((b) => b.id).toList());

    final exerciseIds = itemRows.map((i) => i.exerciseId).toSet();
    final exerciseRows = await _dao.exercisesByIds(exerciseIds);
    final exercises = <int, Exercise>{
      for (final row in exerciseRows) row.id: row.toEntity(),
    };

    final itemsByBlock = <int, List<RoutineItem>>{};
    for (final row in itemRows) {
      final exercise = exercises[row.exerciseId];
      if (exercise == null) continue;
      itemsByBlock.putIfAbsent(row.blockId, () => []).add(
        row.toEntity(exercise),
      );
    }

    final blocksByDay = <int, List<RoutineBlock>>{};
    for (final row in blockRows) {
      blocksByDay.putIfAbsent(row.dayId, () => []).add(
        row.toEntity(items: itemsByBlock[row.id] ?? const []),
      );
    }

    return dayRows
        .map((row) => row.toEntity(blocks: blocksByDay[row.id] ?? const []))
        .toList();
  }
}
