import 'package:drift/drift.dart';

import '../../domain/entity/enums.dart';
import '../../domain/entity/exercise.dart';
import '../../domain/entity/routine.dart';
import '../../domain/entity/routine_block.dart';
import '../../domain/entity/routine_day.dart';
import '../../domain/entity/routine_item.dart';
import '../../domain/entity/set_log.dart';
import '../../domain/entity/workout_session.dart';
import '../database/app_database.dart';

// ── Exercise ──────────────────────────────────────────────────────────────

extension ExerciseRowMapper on ExerciseRow {
  Exercise toEntity() => Exercise(
    id: id,
    name: name,
    bodyPart: BodyPart.fromName(bodyPart),
    subTarget: subTarget,
    equipment: equipment,
    isCustom: isCustom,
    createdAt: createdAt,
  );
}

extension ExerciseMapper on Exercise {
  ExercisesCompanion toCompanion() => ExercisesCompanion(
    name: Value(name),
    bodyPart: Value(bodyPart.name),
    subTarget: Value(subTarget),
    equipment: Value(equipment),
    isCustom: Value(isCustom),
  );
}

// ── Routine ───────────────────────────────────────────────────────────────

extension RoutineRowMapper on RoutineRow {
  Routine toEntity({List<RoutineDay> days = const []}) => Routine(
    id: id,
    name: name,
    description: description,
    sessionMinutes: sessionMinutes,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    days: days,
  );
}

extension RoutineDayRowMapper on RoutineDayRow {
  RoutineDay toEntity({List<RoutineBlock> blocks = const []}) => RoutineDay(
    id: id,
    routineId: routineId,
    order: sortOrder,
    code: code,
    title: title,
    subtitle: subtitle,
    description: description,
    primaryBodyPart: BodyPart.fromName(primaryBodyPart),
    blocks: blocks,
  );
}

extension RoutineDayMapper on RoutineDay {
  RoutineDaysCompanion toCompanion() => RoutineDaysCompanion(
    routineId: Value(routineId),
    sortOrder: Value(order),
    code: Value(code),
    title: Value(title),
    subtitle: Value(subtitle),
    description: Value(description),
    primaryBodyPart: Value(primaryBodyPart.name),
  );
}

extension RoutineBlockRowMapper on RoutineBlockRow {
  RoutineBlock toEntity({List<RoutineItem> items = const []}) => RoutineBlock(
    id: id,
    dayId: dayId,
    order: sortOrder,
    label: label,
    name: name,
    type: BlockType.fromName(type),
    rounds: rounds,
    restSeconds: restSeconds,
    targetMinutes: targetMinutes,
    isCuttable: isCuttable,
    items: items,
  );
}

extension RoutineBlockMapper on RoutineBlock {
  RoutineBlocksCompanion toCompanion() => RoutineBlocksCompanion(
    dayId: Value(dayId),
    sortOrder: Value(order),
    label: Value(label),
    name: Value(name),
    type: Value(type.name),
    rounds: Value(rounds),
    restSeconds: Value(restSeconds),
    targetMinutes: Value(targetMinutes),
    isCuttable: Value(isCuttable),
  );
}

extension RoutineItemRowMapper on RoutineItemRow {
  /// [exercise] must be the row referenced by [RoutineItemRow.exerciseId].
  RoutineItem toEntity(Exercise exercise) => RoutineItem(
    id: id,
    blockId: blockId,
    order: sortOrder,
    exercise: exercise,
    sets: sets,
    repMode: RepMode.fromName(repMode),
    repMin: repMin,
    repMax: repMax,
    durationSeconds: durationSeconds,
    restSecondsOverride: restSecondsOverride,
    targetRir: targetRir,
    note: note,
    alternativeExerciseIds: decodeIdList(alternativeExerciseIds),
  );
}

extension RoutineItemMapper on RoutineItem {
  RoutineItemsCompanion toCompanion() => RoutineItemsCompanion(
    blockId: Value(blockId),
    sortOrder: Value(order),
    exerciseId: Value(exerciseId),
    sets: Value(sets),
    repMode: Value(repMode.name),
    repMin: Value(repMin),
    repMax: Value(repMax),
    durationSeconds: Value(durationSeconds),
    restSecondsOverride: Value(restSecondsOverride),
    targetRir: Value(targetRir),
    note: Value(note),
    alternativeExerciseIds: Value(encodeIdList(alternativeExerciseIds)),
  );
}

// ── Workout ───────────────────────────────────────────────────────────────

extension WorkoutSessionRowMapper on WorkoutSessionRow {
  WorkoutSession toEntity({List<SetLog> setLogs = const []}) => WorkoutSession(
    id: id,
    routineId: routineId,
    dayId: dayId,
    dayCode: dayCode,
    dayTitle: dayTitle,
    date: date,
    startedAt: startedAt,
    endedAt: endedAt,
    status: SessionStatus.fromName(status),
    memo: memo,
    setLogs: setLogs,
  );
}

extension SetLogRowMapper on SetLogRow {
  SetLog toEntity() => SetLog(
    id: id,
    sessionId: sessionId,
    routineItemId: routineItemId,
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    bodyPart: BodyPart.fromName(bodyPart),
    blockLabel: blockLabel,
    itemOrder: itemOrder,
    setIndex: setIndex,
    weight: weight,
    reps: reps,
    durationSeconds: durationSeconds,
    rir: rir,
    restSeconds: restSeconds,
    isCompleted: isCompleted,
    completedAt: completedAt,
  );
}

extension SetLogMapper on SetLog {
  SetLogsCompanion toCompanion() => SetLogsCompanion(
    sessionId: Value(sessionId),
    routineItemId: Value(routineItemId),
    exerciseId: Value(exerciseId),
    exerciseName: Value(exerciseName),
    bodyPart: Value(bodyPart.name),
    blockLabel: Value(blockLabel),
    itemOrder: Value(itemOrder),
    setIndex: Value(setIndex),
    weight: Value(weight),
    reps: Value(reps),
    durationSeconds: Value(durationSeconds),
    rir: Value(rir),
    restSeconds: Value(restSeconds),
    isCompleted: Value(isCompleted),
    completedAt: Value(completedAt),
  );
}

// ── helpers ───────────────────────────────────────────────────────────────

/// `'3,7,12'` → `[3, 7, 12]`
List<int> decodeIdList(String csv) {
  if (csv.trim().isEmpty) return const [];
  return csv
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toList();
}

String encodeIdList(List<int> ids) => ids.join(',');
