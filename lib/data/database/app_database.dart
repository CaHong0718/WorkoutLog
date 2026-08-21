import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/backup_dao.dart';
import 'daos/exercise_dao.dart';
import 'daos/history_dao.dart';
import 'daos/routine_dao.dart';
import 'daos/workout_dao.dart';
import 'seed/routine_seed.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Routines,
    RoutineDays,
    RoutineBlocks,
    RoutineItems,
    WorkoutSessions,
    SetLogs,
  ],
  daos: [RoutineDao, ExerciseDao, WorkoutDao, HistoryDao, BackupDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'workout_log'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Idempotent: only fills an empty database, so it also covers the case
      // where a future migration adds tables after onCreate already ran.
      await seedIfEmpty(this);
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_set_logs_session ON set_logs (session_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_set_logs_exercise '
      'ON set_logs (exercise_id, completed_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_date '
      'ON workout_sessions (date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_status '
      'ON workout_sessions (status)',
    );
  }

  /// Tables whose changes should refresh the routine graph.
  List<TableInfo<Table, dynamic>> get routineGraphTables => [
    routines,
    routineDays,
    routineBlocks,
    routineItems,
    exercises,
  ];
}
