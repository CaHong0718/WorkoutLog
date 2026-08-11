import '../../core/result/result.dart';
import '../entity/date_range.dart';
import '../entity/enums.dart';
import '../entity/exercise_progress_point.dart';
import '../entity/workout_session.dart';

abstract interface class HistoryRepository {
  /// Sessions in [range], newest first. Set logs are included.
  Future<Result<List<WorkoutSession>>> getSessions(DateRange range);

  Future<Result<WorkoutSession>> getSessionDetail(int sessionId);

  /// Sessions on a single calendar day (usually zero or one).
  Future<Result<List<WorkoutSession>>> getSessionsOn(DateTime date);

  /// Completed set counts per body part for the week containing [anyDayInWeek].
  Future<Result<Map<BodyPart, int>>> getWeeklyVolume(DateTime anyDayInWeek);

  Future<Result<List<ExerciseProgressPoint>>> getExerciseProgress(
    int exerciseId, {
    int limit = 30,
  });

  /// Dates with at least one completed session — calendar markers.
  Future<Result<Set<DateTime>>> getWorkoutDates(DateRange range);

  Future<Result<int>> getTotalSessionCount();
}
