import 'package:injectable/injectable.dart';

import '../../core/result/result.dart';
import '../entity/progression_suggestion.dart';
import '../entity/routine_item.dart';
import '../entity/set_log.dart';
import '../entity/workout_session.dart';
import '../repository/workout_repository.dart';

@injectable
class GetInProgressSession {
  const GetInProgressSession(this._repository);

  final WorkoutRepository _repository;

  Future<Result<WorkoutSession?>> call() => _repository.getInProgressSession();
}

@injectable
class StartSession {
  const StartSession(this._repository);

  final WorkoutRepository _repository;

  Future<Result<WorkoutSession>> call(int dayId) =>
      _repository.startSession(dayId);
}

@injectable
class GetSession {
  const GetSession(this._repository);

  final WorkoutRepository _repository;

  Future<Result<WorkoutSession>> call(int sessionId) =>
      _repository.getSession(sessionId);
}

@injectable
class WatchSession {
  const WatchSession(this._repository);

  final WorkoutRepository _repository;

  Stream<WorkoutSession> call(int sessionId) =>
      _repository.watchSession(sessionId);
}

@injectable
class LogSet {
  const LogSet(this._repository);

  final WorkoutRepository _repository;

  Future<Result<int>> call(SetLog log) => _repository.logSet(log);
}

@injectable
class UpdateSet {
  const UpdateSet(this._repository);

  final WorkoutRepository _repository;

  Future<Result<void>> call(SetLog log) => _repository.updateSet(log);
}

@injectable
class DeleteSet {
  const DeleteSet(this._repository);

  final WorkoutRepository _repository;

  Future<Result<void>> call(int setLogId) => _repository.deleteSet(setLogId);
}

@injectable
class CompleteSession {
  const CompleteSession(this._repository);

  final WorkoutRepository _repository;

  Future<Result<void>> call(int sessionId, {String? memo}) =>
      _repository.completeSession(sessionId, memo: memo);
}

@injectable
class AbortSession {
  const AbortSession(this._repository);

  final WorkoutRepository _repository;

  Future<Result<void>> call(int sessionId) =>
      _repository.abortSession(sessionId);
}

@injectable
class GetLastLogsForExercise {
  const GetLastLogsForExercise(this._repository);

  final WorkoutRepository _repository;

  Future<Result<List<SetLog>>> call(int exerciseId, {int limit = 6}) =>
      _repository.getLastLogsForExercise(exerciseId, limit: limit);
}

/// Applies the double-progression rule to the most recent session's logs.
///
/// Increase only when every prescribed set reached the top of the rep range.
@injectable
class SuggestProgression {
  const SuggestProgression(this._repository);

  final WorkoutRepository _repository;

  /// Smallest plate/pin increment we are willing to suggest.
  static const double increment = 1.25;

  /// Percentage added when the rep target is cleared.
  static const double stepRatio = 0.025;

  Future<Result<ProgressionSuggestion>> call(RoutineItem item) async {
    final result = await _repository.getLastLogsForExercise(
      item.exerciseId,
      limit: item.sets * 2,
    );

    return result.map((logs) {
      final name = item.exercise.name;
      final repTarget = item.repMax;

      if (repTarget == null || logs.isEmpty) {
        return ProgressionSuggestion.hold(item.exerciseId, name);
      }

      // Only judge the newest session, not a mix of several.
      final latestSessionId = logs.first.sessionId;
      final lastSetLogs = logs
          .where((log) => log.sessionId == latestSessionId && log.isCompleted)
          .toList();

      if (lastSetLogs.length < item.sets) {
        return ProgressionSuggestion.hold(
          item.exerciseId,
          name,
          currentWeight: lastSetLogs.firstOrNull?.weight,
          reason: '지난 세션에서 목표 세트를 다 채우지 않았습니다.',
        );
      }

      final weights = lastSetLogs
          .map((log) => log.weight)
          .whereType<double>()
          .toList();
      if (weights.isEmpty) {
        return ProgressionSuggestion.hold(
          item.exerciseId,
          name,
          reason: '맨몸 종목은 반복 수로 진행합니다.',
        );
      }

      final currentWeight = weights.reduce((a, b) => a < b ? a : b);
      final clearedEverySet =
          lastSetLogs.every((log) => (log.reps ?? 0) >= repTarget);

      if (!clearedEverySet) {
        return ProgressionSuggestion.hold(
          item.exerciseId,
          name,
          currentWeight: currentWeight,
          reason: '아직 $repTarget회를 모든 세트에서 채우지 못했습니다.',
        );
      }

      final raw = currentWeight * (1 + stepRatio);
      final rounded =
          (raw / increment).ceilToDouble() * increment;
      final suggested = rounded <= currentWeight
          ? currentWeight + increment
          : rounded;

      return ProgressionSuggestion(
        exerciseId: item.exerciseId,
        exerciseName: name,
        shouldIncrease: true,
        currentWeight: currentWeight,
        suggestedWeight: suggested,
        reason: '모든 세트에서 $repTarget회를 채웠습니다. 반복은 구간 하단부터 다시 시작하세요.',
      );
    });
  }
}
