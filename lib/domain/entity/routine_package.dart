import 'package:equatable/equatable.dart';

import 'enums.dart';

/// A routine graph that does not exist in the database yet.
///
/// Mirrors `Routine → RoutineDay → RoutineBlock → RoutineItem` but carries no
/// ids: an exchange file describes a *design*, not rows. Alternatives are
/// therefore referenced by exercise **name** rather than id, and resolved when
/// the package is imported.
///
/// Format spec: `docs/04-ROUTINE-EXCHANGE.md`.
class RoutinePackage extends Equatable {
  const RoutinePackage({
    required this.name,
    this.description,
    this.sessionMinutes = defaultSessionMinutes,
    this.days = const [],
  });

  static const int defaultSessionMinutes = 40;

  final String name;
  final String? description;

  /// Target length of one session, excluding the abs slot.
  final int sessionMinutes;

  final List<RoutineDayDraft> days;

  int get dayCount => days.length;

  int get totalSets => days.fold(0, (sum, day) => sum + day.totalSets);

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final day in days) {
      day.volumeByBodyPart.forEach((part, sets) {
        result.update(part, (v) => v + sets, ifAbsent: () => sets);
      });
    }
    return result;
  }

  /// Every distinct exercise the package references, in first-seen order.
  ///
  /// Import walks this list once to reconcile against the library, so the same
  /// name never produces two rows.
  List<ExerciseDraft> get exercises {
    final seen = <String, ExerciseDraft>{};
    for (final day in days) {
      for (final block in day.blocks) {
        for (final item in block.items) {
          seen.putIfAbsent(item.exercise.name, () => item.exercise);
        }
      }
    }
    return seen.values.toList();
  }

  RoutinePackage copyWith({
    String? name,
    String? description,
    int? sessionMinutes,
    List<RoutineDayDraft>? days,
    bool clearDescription = false,
  }) {
    return RoutinePackage(
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [name, description, sessionMinutes, days];
}

class RoutineDayDraft extends Equatable {
  const RoutineDayDraft({
    required this.code,
    required this.title,
    required this.primaryBodyPart,
    this.subtitle,
    this.description,
    this.blocks = const [],
  });

  final String code;
  final String title;
  final String? subtitle;
  final String? description;
  final BodyPart primaryBodyPart;
  final List<RoutineBlockDraft> blocks;

  int get totalSets => blocks.fold(0, (sum, block) => sum + block.totalSets);

  int get estimatedMinutes =>
      blocks.fold(0, (sum, block) => sum + (block.targetMinutes ?? 0));

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final block in blocks) {
      block.volumeByBodyPart.forEach((part, sets) {
        result.update(part, (v) => v + sets, ifAbsent: () => sets);
      });
    }
    return result;
  }

  @override
  List<Object?> get props => [
    code,
    title,
    subtitle,
    description,
    primaryBodyPart,
    blocks,
  ];
}

class RoutineBlockDraft extends Equatable {
  const RoutineBlockDraft({
    required this.label,
    required this.restSeconds,
    this.name,
    this.type = BlockType.straight,
    this.rounds = 1,
    this.targetMinutes,
    this.isCuttable = true,
    this.items = const [],
  });

  final String label;
  final String? name;
  final BlockType type;

  /// Rounds for a superset; 1 for a straight block.
  final int rounds;

  final int restSeconds;
  final int? targetMinutes;
  final bool isCuttable;
  final List<RoutineItemDraft> items;

  bool get isSuperset => type == BlockType.superset;

  int get totalSets => items.fold(0, (sum, item) => sum + item.volumeSets);

  Map<BodyPart, int> get volumeByBodyPart {
    final result = <BodyPart, int>{};
    for (final item in items) {
      if (item.volumeSets == 0) continue;
      result.update(
        item.exercise.bodyPart,
        (v) => v + item.volumeSets,
        ifAbsent: () => item.volumeSets,
      );
    }
    return result;
  }

  @override
  List<Object?> get props => [
    label,
    name,
    type,
    rounds,
    restSeconds,
    targetMinutes,
    isCuttable,
    items,
  ];
}

class RoutineItemDraft extends Equatable {
  const RoutineItemDraft({
    required this.exercise,
    required this.sets,
    this.repMode = RepMode.range,
    this.repMin,
    this.repMax,
    this.durationSeconds,
    this.restSecondsOverride,
    this.targetRir,
    this.note,
    this.alternativeNames = const [],
  });

  final ExerciseDraft exercise;
  final int sets;
  final RepMode repMode;
  final int? repMin;
  final int? repMax;
  final int? durationSeconds;
  final int? restSecondsOverride;
  final int? targetRir;
  final String? note;

  /// Fallback exercises, by name. Resolved against the file first and the
  /// library second; an unresolved name is dropped with a warning.
  final List<String> alternativeNames;

  /// Sets counting toward weekly volume; a timed slot contributes none.
  int get volumeSets => repMode == RepMode.duration ? 0 : sets;

  RoutineItemDraft copyWith({int? sets}) => RoutineItemDraft(
    exercise: exercise,
    sets: sets ?? this.sets,
    repMode: repMode,
    repMin: repMin,
    repMax: repMax,
    durationSeconds: durationSeconds,
    restSecondsOverride: restSecondsOverride,
    targetRir: targetRir,
    note: note,
    alternativeNames: alternativeNames,
  );

  @override
  List<Object?> get props => [
    exercise,
    sets,
    repMode,
    repMin,
    repMax,
    durationSeconds,
    restSecondsOverride,
    targetRir,
    note,
    alternativeNames,
  ];
}

/// An exercise as described by an exchange file. [name] is the identity used to
/// reconcile against the library on import.
class ExerciseDraft extends Equatable {
  const ExerciseDraft({
    required this.name,
    required this.bodyPart,
    this.subTarget,
    this.equipment,
  });

  final String name;
  final BodyPart bodyPart;
  final String? subTarget;
  final String? equipment;

  @override
  List<Object?> get props => [name, bodyPart, subTarget, equipment];
}

/// Outcome of reading an exchange file.
///
/// Warnings are problems the reader recovered from (a superset whose set count
/// disagreed with its round count, an alternative naming an unknown exercise).
/// They never block the import — they are shown in the preview instead.
class RoutineParseResult extends Equatable {
  const RoutineParseResult({required this.package, this.warnings = const []});

  final RoutinePackage package;
  final List<String> warnings;

  @override
  List<Object?> get props => [package, warnings];
}

/// A serialized routine ready to be written to disk and shared.
class RoutineExportFile extends Equatable {
  const RoutineExportFile({required this.fileName, required this.contents});

  /// `상하체 2분할_20260811.json`
  final String fileName;

  final String contents;

  @override
  List<Object?> get props => [fileName, contents];
}

/// What an import actually did, for the confirmation snackbar.
class RoutineImportReport extends Equatable {
  const RoutineImportReport({
    required this.routineId,
    required this.name,
    required this.dayCount,
    required this.reusedExercises,
    required this.createdExercises,
    this.warnings = const [],
  });

  final int routineId;
  final String name;
  final int dayCount;

  /// Exercises matched to an existing library row by name.
  final int reusedExercises;

  /// Exercises added to the library as custom entries.
  final int createdExercises;

  final List<String> warnings;

  @override
  List<Object?> get props => [
    routineId,
    name,
    dayCount,
    reusedExercises,
    createdExercises,
    warnings,
  ];
}
