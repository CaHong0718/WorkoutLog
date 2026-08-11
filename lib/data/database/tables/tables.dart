import 'package:drift/drift.dart';

/// Exercise library. Seeded from the reference routine; user additions carry
/// [Exercises.isCustom].
@DataClassName('ExerciseRow')
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// [BodyPart.name]
  TextColumn get bodyPart => text().withLength(max: 20)();

  TextColumn get subTarget => text().nullable()();

  TextColumn get equipment => text().nullable()();

  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('RoutineRow')
class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  IntColumn get sessionMinutes => integer().withDefault(const Constant(40))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// One position in the A → B → C → D rotation.
@DataClassName('RoutineDayRow')
class RoutineDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get routineId =>
      integer().references(Routines, #id, onDelete: KeyAction.cascade)();

  /// 0-based rotation position. Named `sortOrder` because `order` is a SQL
  /// keyword.
  IntColumn get sortOrder => integer()();

  TextColumn get code => text().withLength(max: 8)();

  TextColumn get title => text()();

  TextColumn get subtitle => text().nullable()();

  TextColumn get description => text().nullable()();

  /// [BodyPart.name]
  TextColumn get primaryBodyPart => text().withLength(max: 20)();
}

@DataClassName('RoutineBlockRow')
class RoutineBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayId =>
      integer().references(RoutineDays, #id, onDelete: KeyAction.cascade)();

  IntColumn get sortOrder => integer()();

  /// `B1`, `B2`, `복근`
  TextColumn get label => text().withLength(max: 20)();

  TextColumn get name => text().nullable()();

  /// [BlockType.name]
  TextColumn get type =>
      text().withLength(max: 20).withDefault(const Constant('straight'))();

  IntColumn get rounds => integer().withDefault(const Constant(1))();

  IntColumn get restSeconds => integer()();

  IntColumn get targetMinutes => integer().nullable()();

  /// The cut rule may drop this block when time runs short. Never true for B1.
  BoolColumn get isCuttable => boolean().withDefault(const Constant(true))();
}

@DataClassName('RoutineItemRow')
class RoutineItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get blockId =>
      integer().references(RoutineBlocks, #id, onDelete: KeyAction.cascade)();

  IntColumn get sortOrder => integer()();

  IntColumn get exerciseId => integer().references(Exercises, #id)();

  IntColumn get sets => integer()();

  /// [RepMode.name]
  TextColumn get repMode =>
      text().withLength(max: 20).withDefault(const Constant('range'))();

  IntColumn get repMin => integer().nullable()();

  IntColumn get repMax => integer().nullable()();

  IntColumn get durationSeconds => integer().nullable()();

  IntColumn get restSecondsOverride => integer().nullable()();

  IntColumn get targetRir => integer().nullable()();

  TextColumn get note => text().nullable()();

  /// Comma-separated exercise ids used when the machine is occupied.
  TextColumn get alternativeExerciseIds =>
      text().withDefault(const Constant(''))();
}

@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get routineId => integer()();

  /// Set to null if the routine day is deleted; the snapshot columns keep the
  /// record readable.
  IntColumn get dayId =>
      integer().nullable().references(RoutineDays, #id, onDelete: KeyAction.setNull)();

  TextColumn get dayCode => text().withLength(max: 8)();

  TextColumn get dayTitle => text()();

  /// Midnight of the training day — the calendar key.
  DateTimeColumn get date => dateTime()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime().nullable()();

  /// [SessionStatus.name]
  TextColumn get status =>
      text().withLength(max: 20).withDefault(const Constant('inProgress'))();

  TextColumn get memo => text().nullable()();
}

@DataClassName('SetLogRow')
class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();

  /// Intentionally not a foreign key: editing the routine must not rewrite or
  /// remove history.
  IntColumn get routineItemId => integer().nullable()();

  IntColumn get exerciseId => integer()();

  /// Snapshot — survives renames and deletions.
  TextColumn get exerciseName => text()();

  /// Snapshot of [BodyPart.name] — drives weekly volume aggregation.
  TextColumn get bodyPart => text().withLength(max: 20)();

  /// Snapshot of the block label (`B1`).
  TextColumn get blockLabel => text().withLength(max: 20)();

  IntColumn get itemOrder => integer()();

  /// 1-based set number within the exercise.
  IntColumn get setIndex => integer()();

  RealColumn get weight => real().nullable()();

  IntColumn get reps => integer().nullable()();

  IntColumn get durationSeconds => integer().nullable()();

  IntColumn get rir => integer().nullable()();

  /// Rest actually measured after this set.
  IntColumn get restSeconds => integer().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();

  DateTimeColumn get completedAt => dateTime()();
}
