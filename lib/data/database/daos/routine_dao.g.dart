// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_dao.dart';

// ignore_for_file: type=lint
mixin _$RoutineDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoutinesTable get routines => attachedDatabase.routines;
  $RoutineDaysTable get routineDays => attachedDatabase.routineDays;
  $RoutineBlocksTable get routineBlocks => attachedDatabase.routineBlocks;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutineItemsTable get routineItems => attachedDatabase.routineItems;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  RoutineDaoManager get managers => RoutineDaoManager(this);
}

class RoutineDaoManager {
  final _$RoutineDaoMixin _db;
  RoutineDaoManager(this._db);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$RoutineDaysTableTableManager get routineDays =>
      $$RoutineDaysTableTableManager(_db.attachedDatabase, _db.routineDays);
  $$RoutineBlocksTableTableManager get routineBlocks =>
      $$RoutineBlocksTableTableManager(_db.attachedDatabase, _db.routineBlocks);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db.attachedDatabase, _db.routineItems);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
}
