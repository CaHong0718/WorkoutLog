import '../../core/result/result.dart';
import '../entity/set_log.dart';
import '../entity/workout_session.dart';

abstract interface class WorkoutRepository {
  /// The unfinished session, if the app was closed mid-workout.
  Future<Result<WorkoutSession?>> getInProgressSession();

  /// Creates a session for [dayId], snapshotting the day's code and title.
  Future<Result<WorkoutSession>> startSession(int dayId);

  Future<Result<WorkoutSession>> getSession(int sessionId);

  Stream<WorkoutSession> watchSession(int sessionId);

  /// Returns the new row id.
  Future<Result<int>> logSet(SetLog log);

  Future<Result<void>> updateSet(SetLog log);

  Future<Result<void>> deleteSet(int setLogId);

  Future<Result<void>> completeSession(int sessionId, {String? memo});

  Future<Result<void>> abortSession(int sessionId);

  /// Permanently removes a session and every set logged under it.
  Future<Result<void>> deleteSession(int sessionId);

  /// Most recent completed sets for [exerciseId], newest first — used to
  /// pre-fill the weight/rep inputs and to judge progression.
  Future<Result<List<SetLog>>> getLastLogsForExercise(
    int exerciseId, {
    int limit = 6,
  });
}
