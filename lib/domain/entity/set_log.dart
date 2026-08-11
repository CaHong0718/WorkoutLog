import 'package:equatable/equatable.dart';

import 'enums.dart';

/// One performed set.
///
/// Exercise name, body part and block label are **snapshots**: editing the
/// routine later must never rewrite what was actually done.
class SetLog extends Equatable {
  const SetLog({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.blockLabel,
    required this.itemOrder,
    required this.setIndex,
    required this.completedAt,
    this.routineItemId,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.rir,
    this.restSeconds,
    this.isCompleted = true,
  });

  static const int unsavedId = 0;

  final int id;
  final int sessionId;

  /// Null once the originating routine item is deleted.
  final int? routineItemId;

  final int exerciseId;
  final String exerciseName;
  final BodyPart bodyPart;

  /// `B1`, `B3` — snapshot of the block this set belonged to.
  final String blockLabel;

  /// Order of the exercise within the session, for grouping on the detail view.
  final int itemOrder;

  /// 1-based set number within the exercise.
  final int setIndex;

  /// kg. Null for body-weight movements.
  final double? weight;

  final int? reps;

  /// For time-based slots.
  final int? durationSeconds;

  /// Reps in reserve.
  final int? rir;

  /// Rest actually taken after this set, measured by the timer.
  final int? restSeconds;

  /// False when the set was skipped.
  final bool isCompleted;

  final DateTime completedAt;

  /// Tonnage of this set (kg × reps).
  double get volume => (weight ?? 0) * (reps ?? 0);

  /// Epley estimate. Null unless both weight and reps are present.
  double? get estimated1RM {
    final w = weight;
    final r = reps;
    if (w == null || r == null || r <= 0) return null;
    return w * (1 + r / 30);
  }

  /// `60kg × 8`, `맨몸 × 12`, `5:00`
  String get summary {
    if (durationSeconds != null && weight == null && reps == null) {
      final m = durationSeconds! ~/ 60;
      final s = (durationSeconds! % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }
    final left = weight == null ? '맨몸' : '${_trim(weight!)}kg';
    return reps == null ? left : '$left × $reps';
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  SetLog copyWith({
    int? id,
    int? sessionId,
    int? routineItemId,
    int? exerciseId,
    String? exerciseName,
    BodyPart? bodyPart,
    String? blockLabel,
    int? itemOrder,
    int? setIndex,
    double? weight,
    int? reps,
    int? durationSeconds,
    int? rir,
    int? restSeconds,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearWeight = false,
    bool clearReps = false,
    bool clearRir = false,
  }) {
    return SetLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      routineItemId: routineItemId ?? this.routineItemId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      bodyPart: bodyPart ?? this.bodyPart,
      blockLabel: blockLabel ?? this.blockLabel,
      itemOrder: itemOrder ?? this.itemOrder,
      setIndex: setIndex ?? this.setIndex,
      weight: clearWeight ? null : (weight ?? this.weight),
      reps: clearReps ? null : (reps ?? this.reps),
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rir: clearRir ? null : (rir ?? this.rir),
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sessionId,
    routineItemId,
    exerciseId,
    exerciseName,
    bodyPart,
    blockLabel,
    itemOrder,
    setIndex,
    weight,
    reps,
    durationSeconds,
    rir,
    restSeconds,
    isCompleted,
    completedAt,
  ];
}
