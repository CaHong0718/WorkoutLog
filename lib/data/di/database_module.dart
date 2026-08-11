import 'package:injectable/injectable.dart';

import '../database/app_database.dart';
import '../database/daos/exercise_dao.dart';
import '../database/daos/history_dao.dart';
import '../database/daos/routine_dao.dart';
import '../database/daos/workout_dao.dart';

/// Registers the Drift database and its accessors with get_it.
@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  RoutineDao routineDao(AppDatabase db) => db.routineDao;

  @lazySingleton
  ExerciseDao exerciseDao(AppDatabase db) => db.exerciseDao;

  @lazySingleton
  WorkoutDao workoutDao(AppDatabase db) => db.workoutDao;

  @lazySingleton
  HistoryDao historyDao(AppDatabase db) => db.historyDao;
}
