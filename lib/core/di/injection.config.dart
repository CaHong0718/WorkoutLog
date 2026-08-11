// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../domain/repository/exercise_repository.dart' as _i930;
import '../../domain/repository/history_repository.dart' as _i148;
import '../../domain/repository/routine_repository.dart' as _i667;
import '../../domain/repository/workout_repository.dart' as _i611;
import '../../domain/usecase/exercise_usecases.dart' as _i628;
import '../../domain/usecase/history_usecases.dart' as _i839;
import '../../domain/usecase/routine_usecases.dart' as _i15;
import '../../domain/usecase/workout_usecases.dart' as _i250;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i628.GetAllExercises>(
      () => _i628.GetAllExercises(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.WatchExercises>(
      () => _i628.WatchExercises(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.GetExercisesByBodyPart>(
      () => _i628.GetExercisesByBodyPart(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.SearchExercises>(
      () => _i628.SearchExercises(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.GetExercisesByIds>(
      () => _i628.GetExercisesByIds(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.UpsertExercise>(
      () => _i628.UpsertExercise(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i628.DeleteExercise>(
      () => _i628.DeleteExercise(gh<_i930.ExerciseRepository>()),
    );
    gh.factory<_i250.GetInProgressSession>(
      () => _i250.GetInProgressSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.StartSession>(
      () => _i250.StartSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.GetSession>(
      () => _i250.GetSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.WatchSession>(
      () => _i250.WatchSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.LogSet>(() => _i250.LogSet(gh<_i611.WorkoutRepository>()));
    gh.factory<_i250.UpdateSet>(
      () => _i250.UpdateSet(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.DeleteSet>(
      () => _i250.DeleteSet(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.CompleteSession>(
      () => _i250.CompleteSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.AbortSession>(
      () => _i250.AbortSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.GetLastLogsForExercise>(
      () => _i250.GetLastLogsForExercise(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.SuggestProgression>(
      () => _i250.SuggestProgression(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i15.GetActiveRoutine>(
      () => _i15.GetActiveRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.WatchActiveRoutine>(
      () => _i15.WatchActiveRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.GetRoutineDays>(
      () => _i15.GetRoutineDays(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.GetDayDetail>(
      () => _i15.GetDayDetail(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.GetNextDay>(
      () => _i15.GetNextDay(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.UpsertDay>(
      () => _i15.UpsertDay(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.DeleteDay>(
      () => _i15.DeleteDay(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.ReorderDays>(
      () => _i15.ReorderDays(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.UpsertBlock>(
      () => _i15.UpsertBlock(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.DeleteBlock>(
      () => _i15.DeleteBlock(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.ReorderBlocks>(
      () => _i15.ReorderBlocks(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.UpsertItem>(
      () => _i15.UpsertItem(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.DeleteItem>(
      () => _i15.DeleteItem(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.ReorderItems>(
      () => _i15.ReorderItems(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i839.GetSessions>(
      () => _i839.GetSessions(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetSessionDetail>(
      () => _i839.GetSessionDetail(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetSessionsOn>(
      () => _i839.GetSessionsOn(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetWeeklyVolume>(
      () => _i839.GetWeeklyVolume(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetExerciseProgress>(
      () => _i839.GetExerciseProgress(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetWorkoutDates>(
      () => _i839.GetWorkoutDates(gh<_i148.HistoryRepository>()),
    );
    gh.factory<_i839.GetTotalSessionCount>(
      () => _i839.GetTotalSessionCount(gh<_i148.HistoryRepository>()),
    );
    return this;
  }
}
