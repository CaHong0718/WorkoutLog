// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_dao.dart';

// ignore_for_file: type=lint
mixin _$BackupDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $RoutinesTable get routines => attachedDatabase.routines;
  $RoutineDaysTable get routineDays => attachedDatabase.routineDays;
  $RoutineBlocksTable get routineBlocks => attachedDatabase.routineBlocks;
  $RoutineItemsTable get routineItems => attachedDatabase.routineItems;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  $SetLogsTable get setLogs => attachedDatabase.setLogs;
  BackupDaoManager get managers => BackupDaoManager(this);
}

class BackupDaoManager {
  final _$BackupDaoMixin _db;
  BackupDaoManager(this._db);
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
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db.attachedDatabase, _db.setLogs);
}
