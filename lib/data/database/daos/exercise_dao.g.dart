// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutinesTable get routines => attachedDatabase.routines;
  $RoutineDaysTable get routineDays => attachedDatabase.routineDays;
  $RoutineBlocksTable get routineBlocks => attachedDatabase.routineBlocks;
  $RoutineItemsTable get routineItems => attachedDatabase.routineItems;
  ExerciseDaoManager get managers => ExerciseDaoManager(this);
}

class ExerciseDaoManager {
  final _$ExerciseDaoMixin _db;
  ExerciseDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$RoutineDaysTableTableManager get routineDays =>
      $$RoutineDaysTableTableManager(_db.attachedDatabase, _db.routineDays);
  $$RoutineBlocksTableTableManager get routineBlocks =>
      $$RoutineBlocksTableTableManager(_db.attachedDatabase, _db.routineBlocks);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db.attachedDatabase, _db.routineItems);
}
