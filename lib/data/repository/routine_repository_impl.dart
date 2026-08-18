import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../../domain/entity/exercise.dart';
import '../../domain/entity/routine.dart';
import '../../domain/entity/routine_block.dart';
import '../../domain/entity/routine_day.dart';
import '../../domain/entity/routine_item.dart';
import '../../domain/entity/routine_package.dart';
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
  Stream<Routine> watchActiveRoutine() =>
      _watchRoutineGraph(_loadActiveRoutine);

  @override
  Future<Result<List<Routine>>> getRoutines() => runCatching(_loadRoutines);

  @override
  Stream<List<Routine>> watchRoutines() => _watchRoutineGraph(_loadRoutines);

  @override
  Stream<Routine> watchRoutine(int routineId) =>
      _watchRoutineGraph(() => _loadRoutine(routineId));

  @override
  Future<Result<int>> createRoutine(Routine routine) =>
      runCatching(() => _db.transaction(() => _createRoutine(routine)));

  @override
  Future<Result<void>> updateRoutine(Routine routine) => runCatching(
    () => _dao.updateRoutine(routine.id, routine.toUpdateCompanion()),
  );

  @override
  Future<Result<void>> deleteRoutine(int routineId) =>
      runCatching(() => _deleteRoutine(routineId), onError: classifyFailure);

  @override
  Future<Result<void>> setActiveRoutine(int routineId) =>
      runCatching(() => _dao.setActiveRoutine(routineId));

  @override
  Future<Result<RoutineImportReport>> importRoutine(
    RoutinePackage package, {
    bool activate = false,
  }) => runCatching(
    () => _db.transaction(() => _importRoutine(package, activate: activate)),
    onError: classifyFailure,
  );

  @override
  Future<Result<RoutinePackage>> exportRoutine(int routineId) =>
      runCatching(() => _exportRoutine(routineId), onError: classifyFailure);

  @override
  Future<Result<int>> duplicateRoutine(int routineId) => runCatching(() async {
    final source = await _exportRoutine(routineId);
    final copy = source.copyWith(name: await _copyName(source.name));
    final report = await _db.transaction(
      () => _importRoutine(copy, activate: false),
    );
    return report.routineId;
  }, onError: classifyFailure);

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

  /// Re-runs [load] on subscribe and again whenever any table of the routine
  /// graph changes.
  ///
  /// Written with an explicit controller rather than `async*`: a generator
  /// parked on `await for` over the update stream never finishes cancelling,
  /// so closing a bloc that listens to it hangs forever. `asyncMap` also
  /// serialises the reloads — the trigger is paused while a load is in
  /// flight, so a burst of edits cannot emit out of order.
  Stream<T> _watchRoutineGraph<T>(Future<T> Function() load) {
    final updates = _db.tableUpdates(
      TableUpdateQuery.onAllTables(_db.routineGraphTables),
    );

    StreamSubscription<void>? updateSubscription;
    late final StreamController<void> trigger;

    trigger = StreamController<void>(
      onListen: () {
        trigger.add(null); // replay the current graph
        updateSubscription = updates.listen(
          (_) => trigger.add(null),
          onError: trigger.addError,
        );
      },
      onCancel: () async {
        await updateSubscription?.cancel();
        updateSubscription = null;
      },
    );

    return trigger.stream.asyncMap((_) async {
      try {
        return await load();
      } catch (_) {
        // The routine is gone; end the stream after the error instead of
        // re-failing on every unrelated table change.
        unawaited(trigger.close());
        rethrow;
      }
    });
  }

  Future<Routine> _loadActiveRoutine() async {
    final routineRow = await _dao.findActiveRoutine();
    if (routineRow == null) throw const NotFoundException('활성 루틴이 없습니다.');
    final dayRows = await _dao.daysOf(routineRow.id);
    return routineRow.toEntity(days: await _assembleDays(dayRows));
  }

  Future<Routine> _loadRoutine(int routineId) async {
    final routineRow = await _dao.findRoutine(routineId);
    if (routineRow == null) throw const NotFoundException('루틴을 찾을 수 없습니다.');
    final dayRows = await _dao.daysOf(routineId);
    return routineRow.toEntity(days: await _assembleDays(dayRows));
  }

  Future<List<Routine>> _loadRoutines() async {
    final routines = <Routine>[];
    for (final row in await _dao.allRoutines()) {
      final dayRows = await _dao.daysOf(row.id);
      routines.add(row.toEntity(days: await _assembleDays(dayRows)));
    }
    return routines;
  }

  Future<int> _createRoutine(Routine routine) async {
    final hadActive = await _dao.findActiveRoutine() != null;
    final id = await _dao.insertRoutine(routine.toInsertCompanion());
    // Never leave the app without an active routine — the home screen has
    // nothing to show otherwise.
    if (!hadActive) await _dao.setActiveRoutine(id);
    return id;
  }

  Future<void> _deleteRoutine(int routineId) async {
    final all = await _dao.allRoutines();
    if (all.length <= 1) {
      throw const ValidationException('마지막 남은 루틴은 삭제할 수 없습니다.');
    }

    RoutineRow? target;
    for (final row in all) {
      if (row.id == routineId) target = row;
    }
    if (target == null) throw const NotFoundException('루틴을 찾을 수 없습니다.');

    if (await _dao.hasInProgressSession(routineId)) {
      throw const ValidationException(
        '진행 중인 운동이 있는 루틴은 삭제할 수 없습니다. 운동을 끝내거나 중단한 뒤 다시 시도하세요.',
      );
    }

    final wasActive = target.isActive;
    await _db.transaction(() async {
      await _dao.deleteRoutine(routineId);
      if (wasActive) {
        final remaining = all.where((row) => row.id != routineId);
        await _dao.setActiveRoutine(remaining.first.id);
      }
    });
  }

  // ── exchange ────────────────────────────────────────────────────────────

  /// Runs inside a transaction: a half-inserted routine would show up in the
  /// list as an empty shell with no way to tell it apart from a real one.
  Future<RoutineImportReport> _importRoutine(
    RoutinePackage package, {
    required bool activate,
  }) async {
    final warnings = <String>[];
    final hadActive = await _dao.findActiveRoutine() != null;

    // Reconcile exercises by name so history and trend graphs stay attached to
    // the same rows — see docs/04-ROUTINE-EXCHANGE.md §7.1.
    final drafts = package.exercises;
    final idByName = <String, int>{
      for (final row in await _dao.exercisesByNames(drafts.map((d) => d.name)))
        row.name: row.id,
    };

    var reused = 0;
    var created = 0;
    for (final draft in drafts) {
      if (idByName.containsKey(draft.name)) {
        reused++;
        continue;
      }
      idByName[draft.name] = await _dao.insertExercise(
        ExercisesCompanion.insert(
          name: draft.name,
          bodyPart: draft.bodyPart.name,
          subTarget: Value(draft.subTarget),
          equipment: Value(draft.equipment),
          isCustom: const Value(true),
        ),
      );
      created++;
    }

    // An alternative may name an exercise the routine never uses directly, so
    // it is looked up in the library rather than created.
    final unresolved = <String>{
      for (final day in package.days)
        for (final block in day.blocks)
          for (final item in block.items) ...item.alternativeNames,
    }..removeWhere(idByName.containsKey);
    for (final row in await _dao.exercisesByNames(unresolved)) {
      idByName[row.name] = row.id;
      unresolved.remove(row.name);
    }
    for (final name in unresolved) {
      warnings.add('대체 종목 "$name"을 라이브러리에서 찾지 못해 건너뛰었습니다.');
    }

    final routineId = await _dao.insertRoutine(
      RoutinesCompanion.insert(
        name: package.name,
        description: Value(package.description),
        sessionMinutes: Value(package.sessionMinutes),
        isActive: const Value(false),
      ),
    );

    for (var dayIndex = 0; dayIndex < package.days.length; dayIndex++) {
      final day = package.days[dayIndex];
      final dayId = await _dao.upsertDay(
        RoutineDay.unsavedId,
        RoutineDaysCompanion.insert(
          routineId: routineId,
          sortOrder: dayIndex,
          code: day.code,
          title: day.title,
          subtitle: Value(day.subtitle),
          description: Value(day.description),
          primaryBodyPart: day.primaryBodyPart.name,
        ),
      );

      for (var blockIndex = 0; blockIndex < day.blocks.length; blockIndex++) {
        final block = day.blocks[blockIndex];
        final blockId = await _dao.upsertBlock(
          RoutineBlock.unsavedId,
          RoutineBlocksCompanion.insert(
            dayId: dayId,
            sortOrder: blockIndex,
            label: block.label,
            name: Value(block.name),
            type: Value(block.type.name),
            rounds: Value(block.rounds),
            restSeconds: block.restSeconds,
            targetMinutes: Value(block.targetMinutes),
            isCuttable: Value(block.isCuttable),
          ),
        );

        for (var itemIndex = 0; itemIndex < block.items.length; itemIndex++) {
          final item = block.items[itemIndex];
          final alternatives = [
            for (final name in item.alternativeNames)
              if (idByName[name] case final int id) id,
          ];
          await _dao.upsertItem(
            RoutineItem.unsavedId,
            RoutineItemsCompanion.insert(
              blockId: blockId,
              sortOrder: itemIndex,
              exerciseId: idByName[item.exercise.name]!,
              sets: item.sets,
              repMode: Value(item.repMode.name),
              repMin: Value(item.repMin),
              repMax: Value(item.repMax),
              durationSeconds: Value(item.durationSeconds),
              restSecondsOverride: Value(item.restSecondsOverride),
              targetRir: Value(item.targetRir),
              note: Value(item.note),
              alternativeExerciseIds: Value(encodeIdList(alternatives)),
            ),
          );
        }
      }
    }

    if (activate || !hadActive) await _dao.setActiveRoutine(routineId);

    return RoutineImportReport(
      routineId: routineId,
      name: package.name,
      dayCount: package.days.length,
      reusedExercises: reused,
      createdExercises: created,
      warnings: warnings,
    );
  }

  Future<RoutinePackage> _exportRoutine(int routineId) async {
    final row = await _dao.findRoutine(routineId);
    if (row == null) throw const NotFoundException('루틴을 찾을 수 없습니다.');
    final days = await _assembleDays(await _dao.daysOf(routineId));

    // Alternatives are stored as ids but the file refers to names, and an
    // alternative is not always used as a slot of its own.
    final alternativeIds = <int>{
      for (final day in days)
        for (final block in day.blocks)
          for (final item in block.items) ...item.alternativeExerciseIds,
    };
    final nameById = <int, String>{
      for (final day in days)
        for (final block in day.blocks)
          for (final item in block.items) item.exercise.id: item.exercise.name,
      for (final exerciseRow in await _dao.exercisesByIds(alternativeIds))
        exerciseRow.id: exerciseRow.name,
    };

    return RoutinePackage(
      name: row.name,
      description: row.description,
      sessionMinutes: row.sessionMinutes,
      days: [for (final day in days) _dayDraft(day, nameById)],
    );
  }

  RoutineDayDraft _dayDraft(RoutineDay day, Map<int, String> nameById) =>
      RoutineDayDraft(
        code: day.code,
        title: day.title,
        subtitle: day.subtitle,
        description: day.description,
        primaryBodyPart: day.primaryBodyPart,
        blocks: [for (final block in day.blocks) _blockDraft(block, nameById)],
      );

  RoutineBlockDraft _blockDraft(
    RoutineBlock block,
    Map<int, String> nameById,
  ) => RoutineBlockDraft(
    label: block.label,
    name: block.name,
    type: block.type,
    rounds: block.rounds,
    restSeconds: block.restSeconds,
    targetMinutes: block.targetMinutes,
    isCuttable: block.isCuttable,
    items: [for (final item in block.items) _itemDraft(item, nameById)],
  );

  RoutineItemDraft _itemDraft(RoutineItem item, Map<int, String> nameById) =>
      RoutineItemDraft(
        exercise: ExerciseDraft(
          name: item.exercise.name,
          bodyPart: item.exercise.bodyPart,
          subTarget: item.exercise.subTarget,
          equipment: item.exercise.equipment,
        ),
        sets: item.sets,
        repMode: item.repMode,
        repMin: item.repMin,
        repMax: item.repMax,
        durationSeconds: item.durationSeconds,
        restSecondsOverride: item.restSecondsOverride,
        targetRir: item.targetRir,
        note: item.note,
        alternativeNames: [
          for (final id in item.alternativeExerciseIds)
            if (nameById[id] case final String name) name,
        ],
      );

  /// `무분할 40분` → `무분할 40분 복사본`, then ` 복사본 2` and so on.
  Future<String> _copyName(String base) async {
    final taken = (await _dao.allRoutines()).map((row) => row.name).toSet();
    var candidate = _clampName('$base 복사본');
    var counter = 2;
    while (taken.contains(candidate)) {
      candidate = _clampName('$base 복사본 $counter');
      counter++;
    }
    return candidate;
  }

  /// `routines.name` is capped at 120 characters.
  String _clampName(String name) =>
      name.length <= 120 ? name : name.substring(0, 120);

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
      itemsByBlock
          .putIfAbsent(row.blockId, () => [])
          .add(row.toEntity(exercise));
    }

    final blocksByDay = <int, List<RoutineBlock>>{};
    for (final row in blockRows) {
      blocksByDay
          .putIfAbsent(row.dayId, () => [])
          .add(row.toEntity(items: itemsByBlock[row.id] ?? const []));
    }

    return dayRows
        .map((row) => row.toEntity(blocks: blocksByDay[row.id] ?? const []))
        .toList();
  }
}
