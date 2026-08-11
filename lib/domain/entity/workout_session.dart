import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'set_log.dart';

/// One day's training record.
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.id,
    required this.routineId,
    required this.dayCode,
    required this.dayTitle,
    required this.date,
    required this.startedAt,
    this.dayId,
    this.endedAt,
    this.status = SessionStatus.inProgress,
    this.memo,
    this.setLogs = const [],
  });

  static const int unsavedId = 0;

  final int id;
  final int routineId;

  /// Null once the routine day is deleted; [dayCode]/[dayTitle] keep the record
  /// readable.
  final int? dayId;

  final String dayCode;
  final String dayTitle;

  /// Midnight of the training day — the calendar key.
  final DateTime date;

  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final String? memo;

  final List<SetLog> setLogs;

  bool get isInProgress => status == SessionStatus.inProgress;

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  List<SetLog> get completedLogs =>
      setLogs.where((log) => log.isCompleted).toList();

  int get completedSets => completedLogs.length;

  /// Total tonnage in kg.
  double get totalVolume =>
      completedLogs.fold(0, (sum, log) => sum + log.volume);

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final log in completedLogs) {
      result.update(log.bodyPart, (v) => v + 1, ifAbsent: () => 1);
    }
    return result;
  }

  WorkoutSession copyWith({
    int? id,
    int? routineId,
    int? dayId,
    String? dayCode,
    String? dayTitle,
    DateTime? date,
    DateTime? startedAt,
    DateTime? endedAt,
    SessionStatus? status,
    String? memo,
    List<SetLog>? setLogs,
    bool clearEndedAt = false,
    bool clearMemo = false,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayId: dayId ?? this.dayId,
      dayCode: dayCode ?? this.dayCode,
      dayTitle: dayTitle ?? this.dayTitle,
      date: date ?? this.date,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      status: status ?? this.status,
      memo: clearMemo ? null : (memo ?? this.memo),
      setLogs: setLogs ?? this.setLogs,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routineId,
    dayId,
    dayCode,
    dayTitle,
    date,
    startedAt,
    endedAt,
    status,
    memo,
    setLogs,
  ];
}
