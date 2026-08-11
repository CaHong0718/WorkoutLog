import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/date_range.dart';
import '../entity/enums.dart';
import '../entity/exercise_progress_point.dart';
import '../entity/workout_session.dart';
import '../repository/history_repository.dart';

@injectable
class GetSessions {
  const GetSessions(this._repository);

  final HistoryRepository _repository;

  Future<Result<List<WorkoutSession>>> call(DateRange range) =>
      _repository.getSessions(range);
}

@injectable
class GetSessionDetail {
  const GetSessionDetail(this._repository);

  final HistoryRepository _repository;

  Future<Result<WorkoutSession>> call(int sessionId) =>
      _repository.getSessionDetail(sessionId);
}

@injectable
class GetSessionsOn {
  const GetSessionsOn(this._repository);

  final HistoryRepository _repository;

  Future<Result<List<WorkoutSession>>> call(DateTime date) =>
      _repository.getSessionsOn(date);
}

@injectable
class GetWeeklyVolume {
  const GetWeeklyVolume(this._repository);

  final HistoryRepository _repository;

  Future<Result<Map<BodyPart, int>>> call([DateTime? anyDayInWeek]) =>
      _repository.getWeeklyVolume(anyDayInWeek ?? DateTime.now());
}

@injectable
class GetExerciseProgress {
  const GetExerciseProgress(this._repository);

  final HistoryRepository _repository;

  Future<Result<List<ExerciseProgressPoint>>> call(
    int exerciseId, {
    int limit = 30,
  }) => _repository.getExerciseProgress(exerciseId, limit: limit);
}

@injectable
class GetWorkoutDates {
  const GetWorkoutDates(this._repository);

  final HistoryRepository _repository;

  Future<Result<Set<DateTime>>> call(DateRange range) =>
      _repository.getWorkoutDates(range);
}

@injectable
class GetTotalSessionCount {
  const GetTotalSessionCount(this._repository);

  final HistoryRepository _repository;

  Future<Result<int>> call() => _repository.getTotalSessionCount();
}
