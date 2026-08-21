import 'package:equatable/equatable.dart';

import 'enums.dart';
import 'routine_package.dart';

/// Everything the app holds, as a file: the exercise library, every routine,
/// and every finished workout.
///
/// Like [RoutinePackage] it carries **no ids** — a backup describes what was
/// done, not which row numbers this phone happened to use. Exercises and
/// routines are referenced by name, sessions by their start instant.
///
/// Format spec: `docs/07-BACKUP.md`.
class BackupPackage extends Equatable {
  const BackupPackage({
    this.exercises = const [],
    this.routines = const [],
    this.sessions = const [],
  });

  /// The whole library, including movements no routine references any more —
  /// dropping those would erase them from the trend picker after a restore.
  final List<BackupExercise> exercises;

  final List<BackupRoutine> routines;

  /// Finished workouts only. An in-progress session is this phone's current
  /// state, not a record, and is never exported (`docs/07-BACKUP.md` §5).
  final List<SessionDraft> sessions;

  int get setCount => sessions.fold(0, (sum, s) => sum + s.sets.length);

  BackupSummary get summary {
    DateTime? first;
    DateTime? last;
    for (final session in sessions) {
      if (first == null || session.date.isBefore(first)) first = session.date;
      if (last == null || session.date.isAfter(last)) last = session.date;
    }
    return BackupSummary(
      routineCount: routines.length,
      exerciseCount: exercises.length,
      sessionCount: sessions.length,
      setCount: setCount,
      firstSessionDate: first,
      lastSessionDate: last,
    );
  }

  @override
  List<Object?> get props => [exercises, routines, sessions];
}

/// A library entry. [name] is the identity used to reconcile on restore.
class BackupExercise extends Equatable {
  const BackupExercise({
    required this.name,
    required this.bodyPart,
    this.subTarget,
    this.equipment,
    this.isCustom = false,
  });

  final String name;
  final BodyPart bodyPart;
  final String? subTarget;
  final String? equipment;
  final bool isCustom;

  /// The same movement in the shape routine import already understands.
  ExerciseDraft toDraft() => ExerciseDraft(
    name: name,
    bodyPart: bodyPart,
    subTarget: subTarget,
    equipment: equipment,
  );

  @override
  List<Object?> get props => [name, bodyPart, subTarget, equipment, isCustom];
}

/// A routine inside a backup: the exchange package plus which one was in use.
///
/// [package] is exactly what a routine `.json` carries, so both files are read
/// and written by the same code — see `docs/07-BACKUP.md` §4.
class BackupRoutine extends Equatable {
  const BackupRoutine({required this.package, this.isActive = false});

  final RoutinePackage package;

  /// Honoured by a replace restore only; merging leaves the active routine
  /// alone.
  final bool isActive;

  String get name => package.name;

  @override
  List<Object?> get props => [package, isActive];
}

/// One finished workout, without ids.
class SessionDraft extends Equatable {
  const SessionDraft({
    required this.dayCode,
    required this.dayTitle,
    required this.date,
    required this.startedAt,
    this.routineName,
    this.endedAt,
    this.status = SessionStatus.completed,
    this.memo,
    this.sets = const [],
  });

  /// Name of the routine this was run from. Null once that routine is gone —
  /// the snapshots below keep the record readable either way.
  final String? routineName;

  final String dayCode;
  final String dayTitle;

  /// Midnight of the training day — the calendar key.
  final DateTime date;

  /// The identity of a session: nobody starts two workouts in the same
  /// millisecond, so a merge restore skips anything that already has this.
  final DateTime startedAt;

  final DateTime? endedAt;
  final SessionStatus status;
  final String? memo;

  final List<SetLogDraft> sets;

  @override
  List<Object?> get props => [
    routineName,
    dayCode,
    dayTitle,
    date,
    startedAt,
    endedAt,
    status,
    memo,
    sets,
  ];
}

/// One performed set, carrying the same snapshots `SetLog` does.
class SetLogDraft extends Equatable {
  const SetLogDraft({
    required this.exerciseName,
    required this.bodyPart,
    required this.blockLabel,
    required this.itemOrder,
    required this.setIndex,
    required this.completedAt,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.rir,
    this.restSeconds,
    this.isCompleted = true,
  });

  final String exerciseName;

  /// Snapshot — weekly volume is aggregated on this, not on the library row.
  final BodyPart bodyPart;

  final String blockLabel;
  final int itemOrder;
  final int setIndex;

  /// kg. Null and `0` both mean body weight.
  final double? weight;

  final int? reps;
  final int? durationSeconds;
  final int? rir;
  final int? restSeconds;
  final bool isCompleted;
  final DateTime completedAt;

  @override
  List<Object?> get props => [
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

/// How a restore treats what is already in the database.
enum BackupRestoreMode {
  /// Keep everything; add what is missing. Nothing is ever deleted.
  merge('합치기'),

  /// Empty every table first, then insert the backup. Not reversible.
  replace('덮어쓰기');

  const BackupRestoreMode(this.label);

  final String label;
}

/// Counts shown before and after a restore, and on the backup screen for the
/// database as it stands.
class BackupSummary extends Equatable {
  const BackupSummary({
    this.routineCount = 0,
    this.exerciseCount = 0,
    this.sessionCount = 0,
    this.setCount = 0,
    this.firstSessionDate,
    this.lastSessionDate,
  });

  final int routineCount;
  final int exerciseCount;
  final int sessionCount;
  final int setCount;

  final DateTime? firstSessionDate;
  final DateTime? lastSessionDate;

  bool get hasSessions => sessionCount > 0;

  @override
  List<Object?> get props => [
    routineCount,
    exerciseCount,
    sessionCount,
    setCount,
    firstSessionDate,
    lastSessionDate,
  ];
}

/// Outcome of reading a backup file.
///
/// Warnings never block the restore — they are listed in the preview so the
/// user can decide with them in view (`docs/07-BACKUP.md` §11).
class BackupParseResult extends Equatable {
  const BackupParseResult({required this.package, this.warnings = const []});

  final BackupPackage package;
  final List<String> warnings;

  @override
  List<Object?> get props => [package, warnings];
}

/// A serialized backup ready to be written to disk and shared.
class BackupExportFile extends Equatable {
  const BackupExportFile({required this.fileName, required this.contents});

  /// `운동기록_20260821.json`
  final String fileName;

  final String contents;

  @override
  List<Object?> get props => [fileName, contents];
}

/// What a restore actually did, for the confirmation message.
class BackupImportReport extends Equatable {
  const BackupImportReport({
    required this.mode,
    this.importedSessions = 0,
    this.skippedSessions = 0,
    this.importedSets = 0,
    this.createdRoutines = 0,
    this.skippedRoutines = 0,
    this.reusedExercises = 0,
    this.createdExercises = 0,
    this.warnings = const [],
  });

  final BackupRestoreMode mode;

  final int importedSessions;

  /// Already present — matched by `startedAt`. Always 0 after a replace.
  final int skippedSessions;

  final int importedSets;

  final int createdRoutines;

  /// A routine of the same name was already there and was left untouched.
  final int skippedRoutines;

  final int reusedExercises;
  final int createdExercises;

  final List<String> warnings;

  @override
  List<Object?> get props => [
    mode,
    importedSessions,
    skippedSessions,
    importedSets,
    createdRoutines,
    skippedRoutines,
    reusedExercises,
    createdExercises,
    warnings,
  ];
}
