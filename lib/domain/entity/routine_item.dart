import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'exercise.dart';

/// One exercise slot inside a block, with its set/rep prescription.
class RoutineItem extends Equatable {
  const RoutineItem({
    required this.id,
    required this.blockId,
    required this.order,
    required this.exercise,
    required this.sets,
    this.repMode = RepMode.range,
    this.repMin,
    this.repMax,
    this.durationSeconds,
    this.restSecondsOverride,
    this.targetRir,
    this.note,
    this.alternativeExerciseIds = const [],
  });

  static const int unsavedId = 0;

  final int id;
  final int blockId;

  /// 0-based position inside the block.
  final int order;

  /// Joined on read; the caller supplies it when creating.
  final Exercise exercise;

  /// For a superset item this equals the block's round count.
  final int sets;

  final RepMode repMode;
  final int? repMin;
  final int? repMax;

  /// Set only when [repMode] is [RepMode.duration].
  final int? durationSeconds;

  /// Overrides the block's rest when this slot needs a different one.
  final int? restSecondsOverride;

  final int? targetRir;

  /// Execution tip carried over from the reference document.
  final String? note;

  /// Fallbacks when the machine is occupied.
  final List<int> alternativeExerciseIds;

  int get exerciseId => exercise.id;

  BodyPart get bodyPart => exercise.bodyPart;

  /// `4 × AMRAP`, `3 × 8–10`, `5분`
  String get prescription => switch (repMode) {
    RepMode.amrap => '$sets × AMRAP',
    RepMode.duration => '${(durationSeconds ?? 0) ~/ 60}분',
    RepMode.range when repMin != null && repMax != null && repMin != repMax =>
      '$sets × $repMin–$repMax',
    RepMode.range => '$sets × ${repMax ?? repMin ?? 0}',
  };

  /// Sets that count toward weekly volume; the timed abs slot counts as 0.
  int get volumeSets => repMode == RepMode.duration ? 0 : sets;

  RoutineItem copyWith({
    int? id,
    int? blockId,
    int? order,
    Exercise? exercise,
    int? sets,
    RepMode? repMode,
    int? repMin,
    int? repMax,
    int? durationSeconds,
    int? restSecondsOverride,
    int? targetRir,
    String? note,
    List<int>? alternativeExerciseIds,
    bool clearRepRange = false,
    bool clearDuration = false,
    bool clearRestOverride = false,
    bool clearTargetRir = false,
    bool clearNote = false,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      order: order ?? this.order,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      repMode: repMode ?? this.repMode,
      repMin: clearRepRange ? null : (repMin ?? this.repMin),
      repMax: clearRepRange ? null : (repMax ?? this.repMax),
      durationSeconds:
          clearDuration ? null : (durationSeconds ?? this.durationSeconds),
      restSecondsOverride: clearRestOverride
          ? null
          : (restSecondsOverride ?? this.restSecondsOverride),
      targetRir: clearTargetRir ? null : (targetRir ?? this.targetRir),
      note: clearNote ? null : (note ?? this.note),
      alternativeExerciseIds:
          alternativeExerciseIds ?? this.alternativeExerciseIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    blockId,
    order,
    exercise,
    sets,
    repMode,
    repMin,
    repMax,
    durationSeconds,
    restSecondsOverride,
    targetRir,
    note,
    alternativeExerciseIds,
  ];
}
