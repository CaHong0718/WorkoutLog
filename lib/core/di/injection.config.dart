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

import '../../data/database/app_database.dart' as _i160;
import '../../data/database/daos/exercise_dao.dart' as _i248;
import '../../data/database/daos/history_dao.dart' as _i615;
import '../../data/database/daos/routine_dao.dart' as _i229;
import '../../data/database/daos/workout_dao.dart' as _i535;
import '../../data/di/database_module.dart' as _i883;
import '../../data/exchange/routine_codec.dart' as _i480;
import '../../data/repository/exercise_repository_impl.dart' as _i928;
import '../../data/repository/history_repository_impl.dart' as _i916;
import '../../data/repository/routine_repository_impl.dart' as _i64;
import '../../data/repository/workout_repository_impl.dart' as _i1004;
import '../../domain/repository/exercise_repository.dart' as _i930;
import '../../domain/repository/history_repository.dart' as _i148;
import '../../domain/repository/routine_exchange.dart' as _i372;
import '../../domain/repository/routine_repository.dart' as _i667;
import '../../domain/repository/workout_repository.dart' as _i611;
import '../../domain/usecase/exercise_usecases.dart' as _i628;
import '../../domain/usecase/history_usecases.dart' as _i839;
import '../../domain/usecase/routine_usecases.dart' as _i15;
import '../../domain/usecase/workout_usecases.dart' as _i250;
import '../../presentation/history/bloc/history_bloc.dart' as _i1045;
import '../../presentation/history/bloc/session_detail_bloc.dart' as _i918;
import '../../presentation/history/bloc/stats_bloc.dart' as _i122;
import '../../presentation/home/bloc/home_bloc.dart' as _i315;
import '../../presentation/routine_edit/bloc/day_edit_bloc.dart' as _i514;
import '../../presentation/routine_edit/bloc/exercise_library_bloc.dart'
    as _i1038;
import '../../presentation/routine_edit/bloc/routine_bloc.dart' as _i937;
import '../../presentation/routine_edit/bloc/routine_list_bloc.dart' as _i191;
import '../../presentation/session/bloc/session_bloc.dart' as _i373;
import '../notification/rest_notifier.dart' as _i204;
import '../platform/routine_file_io.dart' as _i358;
import '../platform/shared_routine_receiver.dart' as _i235;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    gh.lazySingleton<_i204.RestNotifier>(() => _i204.RestNotifier());
    gh.lazySingleton<_i358.RoutineFileIo>(() => const _i358.RoutineFileIo());
    gh.lazySingleton<_i160.AppDatabase>(() => databaseModule.database);
    gh.lazySingleton<_i372.RoutineExchange>(() => const _i480.RoutineCodec());
    gh.factory<_i15.ParseRoutineFile>(
      () => _i15.ParseRoutineFile(gh<_i372.RoutineExchange>()),
    );
    gh.lazySingleton<_i229.RoutineDao>(
      () => databaseModule.routineDao(gh<_i160.AppDatabase>()),
    );
    gh.lazySingleton<_i248.ExerciseDao>(
      () => databaseModule.exerciseDao(gh<_i160.AppDatabase>()),
    );
    gh.lazySingleton<_i535.WorkoutDao>(
      () => databaseModule.workoutDao(gh<_i160.AppDatabase>()),
    );
    gh.lazySingleton<_i615.HistoryDao>(
      () => databaseModule.historyDao(gh<_i160.AppDatabase>()),
    );
    gh.lazySingleton<_i235.SharedRoutineReceiver>(
      () => _i235.SharedRoutineReceiver(gh<_i358.RoutineFileIo>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i148.HistoryRepository>(
      () => _i916.HistoryRepositoryImpl(gh<_i615.HistoryDao>()),
    );
    gh.lazySingleton<_i930.ExerciseRepository>(
      () => _i928.ExerciseRepositoryImpl(gh<_i248.ExerciseDao>()),
    );
    gh.lazySingleton<_i611.WorkoutRepository>(
      () => _i1004.WorkoutRepositoryImpl(
        gh<_i535.WorkoutDao>(),
        gh<_i229.RoutineDao>(),
        gh<_i160.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i667.RoutineRepository>(
      () => _i64.RoutineRepositoryImpl(
        gh<_i229.RoutineDao>(),
        gh<_i160.AppDatabase>(),
      ),
    );
    gh.factory<_i15.ExportRoutine>(
      () => _i15.ExportRoutine(
        gh<_i667.RoutineRepository>(),
        gh<_i372.RoutineExchange>(),
      ),
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
    gh.factory<_i1045.HistoryBloc>(
      () => _i1045.HistoryBloc(
        gh<_i839.GetWorkoutDates>(),
        gh<_i839.GetSessions>(),
        gh<_i839.GetSessionsOn>(),
        gh<_i839.GetWeeklyVolume>(),
        gh<_i839.GetTotalSessionCount>(),
      ),
    );
    gh.factory<_i15.GetActiveRoutine>(
      () => _i15.GetActiveRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.WatchActiveRoutine>(
      () => _i15.WatchActiveRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.GetRoutines>(
      () => _i15.GetRoutines(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.WatchRoutines>(
      () => _i15.WatchRoutines(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.WatchRoutine>(
      () => _i15.WatchRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.CreateRoutine>(
      () => _i15.CreateRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.UpdateRoutine>(
      () => _i15.UpdateRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.DeleteRoutine>(
      () => _i15.DeleteRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.SetActiveRoutine>(
      () => _i15.SetActiveRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.DuplicateRoutine>(
      () => _i15.DuplicateRoutine(gh<_i667.RoutineRepository>()),
    );
    gh.factory<_i15.ImportRoutine>(
      () => _i15.ImportRoutine(gh<_i667.RoutineRepository>()),
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
    gh.factory<_i122.StatsBloc>(
      () => _i122.StatsBloc(
        gh<_i15.GetActiveRoutine>(),
        gh<_i839.GetWeeklyVolume>(),
        gh<_i839.GetSessions>(),
        gh<_i839.GetExerciseProgress>(),
      ),
    );
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
    gh.factory<_i250.DeleteSession>(
      () => _i250.DeleteSession(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.GetLastLogsForExercise>(
      () => _i250.GetLastLogsForExercise(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i250.SuggestProgression>(
      () => _i250.SuggestProgression(gh<_i611.WorkoutRepository>()),
    );
    gh.factory<_i937.RoutineBloc>(
      () => _i937.RoutineBloc(
        gh<_i15.WatchActiveRoutine>(),
        gh<_i15.WatchRoutine>(),
        gh<_i15.UpsertDay>(),
        gh<_i15.DeleteDay>(),
        gh<_i15.ReorderDays>(),
      ),
    );
    gh.factoryParam<_i514.DayEditBloc, int, dynamic>(
      (dayId, _) => _i514.DayEditBloc(
        dayId,
        gh<_i15.GetDayDetail>(),
        gh<_i628.GetAllExercises>(),
        gh<_i15.UpsertDay>(),
        gh<_i15.UpsertBlock>(),
        gh<_i15.DeleteBlock>(),
        gh<_i15.ReorderBlocks>(),
        gh<_i15.UpsertItem>(),
        gh<_i15.DeleteItem>(),
        gh<_i15.ReorderItems>(),
      ),
    );
    gh.factory<_i315.HomeBloc>(
      () => _i315.HomeBloc(
        gh<_i15.GetActiveRoutine>(),
        gh<_i15.WatchActiveRoutine>(),
        gh<_i15.GetNextDay>(),
        gh<_i250.GetInProgressSession>(),
        gh<_i839.GetWeeklyVolume>(),
        gh<_i250.StartSession>(),
        gh<_i250.AbortSession>(),
      ),
    );
    gh.factory<_i1038.ExerciseLibraryBloc>(
      () => _i1038.ExerciseLibraryBloc(
        gh<_i628.WatchExercises>(),
        gh<_i628.UpsertExercise>(),
        gh<_i628.DeleteExercise>(),
      ),
    );
    gh.factory<_i191.RoutineListBloc>(
      () => _i191.RoutineListBloc(
        gh<_i15.WatchRoutines>(),
        gh<_i15.SetActiveRoutine>(),
        gh<_i15.CreateRoutine>(),
        gh<_i15.UpdateRoutine>(),
        gh<_i15.DeleteRoutine>(),
        gh<_i15.DuplicateRoutine>(),
        gh<_i15.ParseRoutineFile>(),
        gh<_i15.ImportRoutine>(),
        gh<_i15.ExportRoutine>(),
        gh<_i358.RoutineFileIo>(),
      ),
    );
    gh.factoryParam<_i918.SessionDetailBloc, int, dynamic>(
      (sessionId, _) => _i918.SessionDetailBloc(
        sessionId,
        gh<_i839.GetSessionDetail>(),
        gh<_i250.DeleteSession>(),
      ),
    );
    gh.factoryParam<_i373.SessionBloc, int, dynamic>(
      (sessionId, _) => _i373.SessionBloc(
        sessionId,
        gh<_i250.GetSession>(),
        gh<_i15.GetDayDetail>(),
        gh<_i250.LogSet>(),
        gh<_i250.UpdateSet>(),
        gh<_i250.DeleteSet>(),
        gh<_i250.CompleteSession>(),
        gh<_i250.AbortSession>(),
        gh<_i250.GetLastLogsForExercise>(),
        gh<_i628.GetExercisesByIds>(),
        gh<_i250.SuggestProgression>(),
        gh<_i204.RestNotifier>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i883.DatabaseModule {}
