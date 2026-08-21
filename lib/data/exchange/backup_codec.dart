import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../core/result/result.dart';
import '../../domain/entity/backup_package.dart';
import '../../domain/entity/enums.dart';
import '../../domain/repository/backup_exchange.dart';
import '../../domain/repository/routine_exchange.dart';
import 'json_reader.dart';
import 'routine_codec.dart';

/// Reads and writes `docs/07-BACKUP.md` documents.
///
/// Routines inside a backup are handed to [RoutineExchange] untouched, so the
/// routine schema has exactly one definition no matter which file it appears in.
///
/// Like [RoutineCodec] this depends on nothing but `dart:convert` and the
/// domain: `tools/validate_backup.dart` runs this class from the command line,
/// so a file that validates there restores on the phone.
@LazySingleton(as: BackupExchange)
class BackupCodec implements BackupExchange {
  const BackupCodec(this._routines);

  final RoutineExchange _routines;

  static const String formatId = 'workout-log.backup';
  static const int formatVersion = 1;

  /// A broken export can produce one problem per set. The preview lists this
  /// many and then says how many more there were — a wall of 3,000 lines helps
  /// nobody.
  static const int maxReportedErrors = 40;

  @override
  Result<BackupParseResult> decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException catch (error) {
      return Err(
        RoutineFormatFailure(
          'JSON을 읽을 수 없습니다.',
          errors: [error.message],
          cause: error,
        ),
      );
    }

    final decoder = _BackupDecoder(_routines);
    final package = decoder.read(root);
    if (package == null || decoder.errors.isNotEmpty) {
      return Err(
        RoutineFormatFailure(
          '백업 파일 형식이 올바르지 않습니다.',
          errors: _trimErrors(decoder.errors),
        ),
      );
    }
    return Ok(
      BackupParseResult(
        package: package,
        warnings: decoder.warnings.toSet().toList(),
      ),
    );
  }

  @override
  String encode(BackupPackage package, {DateTime? exportedAt}) {
    final summary = package.summary;
    final document = <String, Object?>{
      'format': formatId,
      'version': formatVersion,
      if (exportedAt != null) 'exportedAt': exportedAt.toIso8601String(),
      // For whoever opens the file in a text editor. The reader ignores it and
      // counts the arrays instead.
      'summary': <String, Object?>{
        'routines': summary.routineCount,
        'exercises': summary.exerciseCount,
        'sessions': summary.sessionCount,
        'sets': summary.setCount,
      },
      'exercises': [
        for (final exercise in package.exercises) _exerciseJson(exercise),
      ],
      'routines': [
        for (final routine in package.routines) _routineJson(routine),
      ],
      'sessions': [
        for (final session in package.sessions) _sessionJson(session),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(document);
  }

  @override
  String fileNameFor(DateTime now) {
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return '운동기록_$stamp.json';
  }

  // ── encode helpers ──────────────────────────────────────────────────────
  //
  // Null and default-valued keys are omitted. With thousands of sets in a
  // file that rule alone decides whether it is a megabyte or three.

  Map<String, Object?> _exerciseJson(BackupExercise exercise) =>
      <String, Object?>{
        'name': exercise.name,
        'bodyPart': exercise.bodyPart.name,
        if (exercise.subTarget != null) 'subTarget': exercise.subTarget,
        if (exercise.equipment != null) 'equipment': exercise.equipment,
        if (exercise.isCustom) 'isCustom': true,
      };

  Map<String, Object?> _routineJson(BackupRoutine routine) {
    final body = _routines.encodeRoutineBody(routine.package);
    // `days` is lifted out and put back last so `isActive` does not end up
    // below a few hundred lines of blocks.
    final days = body.remove('days');
    return <String, Object?>{
      ...body,
      if (routine.isActive) 'isActive': true,
      'days': days,
    };
  }

  Map<String, Object?> _sessionJson(SessionDraft session) => <String, Object?>{
    if (session.routineName != null) 'routine': session.routineName,
    'dayCode': session.dayCode,
    'dayTitle': session.dayTitle,
    'date': jsonDate(session.date),
    'startedAt': session.startedAt.toIso8601String(),
    if (session.endedAt != null) 'endedAt': session.endedAt!.toIso8601String(),
    'status': session.status.name,
    if (session.memo != null) 'memo': session.memo,
    'sets': [for (final set in session.sets) _setJson(set)],
  };

  Map<String, Object?> _setJson(SetLogDraft set) => <String, Object?>{
    'exercise': set.exerciseName,
    'bodyPart': set.bodyPart.name,
    'blockLabel': set.blockLabel,
    'itemOrder': set.itemOrder,
    'setIndex': set.setIndex,
    if (set.weight != null) 'weight': _number(set.weight!),
    if (set.reps != null) 'reps': set.reps,
    if (set.durationSeconds != null) 'durationSeconds': set.durationSeconds,
    if (set.rir != null) 'rir': set.rir,
    if (set.restSeconds != null) 'restSeconds': set.restSeconds,
    if (!set.isCompleted) 'isCompleted': false,
    'completedAt': set.completedAt.toIso8601String(),
  };

  /// `60` rather than `60.0`; the reader accepts both.
  static num _number(double value) =>
      value == value.roundToDouble() ? value.toInt() : value;

  static List<String> _trimErrors(List<String> errors) {
    if (errors.length <= maxReportedErrors) return errors;
    return [
      ...errors.take(maxReportedErrors),
      '…외 ${errors.length - maxReportedErrors}개의 문제가 더 있습니다.',
    ];
  }
}

// ── decoding ──────────────────────────────────────────────────────────────

class _BackupDecoder extends JsonReader {
  _BackupDecoder(this._routines);

  final RoutineExchange _routines;

  BackupPackage? read(Object? root) {
    final document = object(root, '루트');
    if (document == null) return null;

    final format = document['format'];
    if (format != BackupCodec.formatId) {
      errors.add(
        'format: "${BackupCodec.formatId}"이어야 합니다 (${jsonDisplay(format)}). '
        '${format == RoutineCodec.formatId ? '루틴 파일입니다 — 루틴 목록의 가져오기로 넣으세요.' : '백업 파일이 맞는지 확인하세요.'}',
      );
    }

    final version = jsonInteger(document['version']);
    if (version == null) {
      errors.add('version: 정수여야 합니다 (${jsonDisplay(document['version'])})');
    } else if (version != BackupCodec.formatVersion) {
      errors.add(
        'version: 이 앱은 ${BackupCodec.formatVersion}만 읽을 수 있습니다 ($version)',
      );
    }

    final exercises = <BackupExercise>[];
    final rawExercises = optionalList(document, 'exercises', '');
    for (var i = 0; i < rawExercises.length; i++) {
      final exercise = _readExercise(rawExercises[i], 'exercises[$i]');
      if (exercise != null) exercises.add(exercise);
    }

    final routines = _readRoutines(optionalList(document, 'routines', ''));

    final sessions = <SessionDraft>[];
    final rawSessions = optionalList(document, 'sessions', '');
    for (var i = 0; i < rawSessions.length; i++) {
      final session = _readSession(rawSessions[i], 'sessions[$i]');
      if (session != null) sessions.add(session);
    }

    if (errors.isNotEmpty) return null;
    return BackupPackage(
      exercises: exercises,
      routines: routines,
      sessions: sessions,
    );
  }

  BackupExercise? _readExercise(Object? value, String path) {
    final map = object(value, path);
    if (map == null) return null;

    final name = requiredString(map, 'name', path, maxLength: 120);
    final bodyPart = requiredEnum(
      map,
      'bodyPart',
      path,
      BodyPart.values,
      (e) => e.name,
    );
    final subTarget = optionalString(map, 'subTarget', path);
    final equipment = optionalString(map, 'equipment', path);
    final isCustom = optionalBool(map, 'isCustom', path) ?? false;

    if (name == null || bodyPart == null) return null;
    return BackupExercise(
      name: name,
      bodyPart: bodyPart,
      subTarget: subTarget,
      equipment: equipment,
      isCustom: isCustom,
    );
  }

  /// Each entry is a routine exchange body, read by the routine codec itself.
  /// Its problems are already prefixed with this entry's path, so they drop
  /// straight into this file's list.
  List<BackupRoutine> _readRoutines(List<Object?> raw) {
    final routines = <BackupRoutine>[];
    var activeTaken = false;

    for (var i = 0; i < raw.length; i++) {
      final path = 'routines[$i]';
      final parsed = _routines.decodeRoutineBody(raw[i], path: path);
      errors.addAll(parsed.errors);
      warnings.addAll(parsed.warnings);

      final package = parsed.package;
      if (package == null) continue;

      final entry = raw[i];
      var isActive =
          entry is Map<String, Object?>
              ? optionalBool(entry, 'isActive', path) ?? false
              : false;
      if (isActive && activeTaken) {
        warnings.add(
          '$path: 사용 중으로 표시된 루틴이 여럿입니다. 먼저 나온 것만 사용 중으로 둡니다.',
        );
        isActive = false;
      }
      activeTaken = activeTaken || isActive;

      routines.add(BackupRoutine(package: package, isActive: isActive));
    }
    return routines;
  }

  SessionDraft? _readSession(Object? value, String path) {
    final map = object(value, path);
    if (map == null) return null;

    final dayCode = requiredString(map, 'dayCode', path, maxLength: 8);
    final dayTitle = requiredString(map, 'dayTitle', path, maxLength: 120);
    final date = requiredDate(map, 'date', path);
    final startedAt = requiredDateTime(map, 'startedAt', path);
    final endedAt = optionalDateTime(map, 'endedAt', path);
    final status =
        optionalEnum(
          map,
          'status',
          path,
          SessionStatus.values,
          (e) => e.name,
        ) ??
        SessionStatus.completed;

    // A live session is this phone's current state, not a record. Letting one
    // in would put a ghost "이어서 하기" banner on the home screen.
    if (status == SessionStatus.inProgress) {
      errors.add('$path.status: 진행 중인 운동은 백업에 담을 수 없습니다.');
    }
    if (startedAt != null && endedAt != null && endedAt.isBefore(startedAt)) {
      errors.add('$path.endedAt: startedAt보다 빠릅니다.');
    }

    final sets = <SetLogDraft>[];
    final rawSets = optionalList(map, 'sets', path);
    for (var i = 0; i < rawSets.length; i++) {
      final set = _readSet(rawSets[i], '$path.sets[$i]');
      if (set != null) sets.add(set);
    }

    if (dayCode == null ||
        dayTitle == null ||
        date == null ||
        startedAt == null) {
      return null;
    }
    return SessionDraft(
      routineName: optionalString(map, 'routine', path),
      dayCode: dayCode,
      dayTitle: dayTitle,
      date: date,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
      memo: optionalString(map, 'memo', path),
      sets: sets,
    );
  }

  SetLogDraft? _readSet(Object? value, String path) {
    final map = object(value, path);
    if (map == null) return null;

    final exerciseName = requiredString(map, 'exercise', path, maxLength: 120);
    final bodyPart = requiredEnum(
      map,
      'bodyPart',
      path,
      BodyPart.values,
      (e) => e.name,
    );
    final blockLabel = requiredString(map, 'blockLabel', path, maxLength: 20);
    final itemOrder = requiredInt(map, 'itemOrder', path, min: 0, max: 999);
    final setIndex = requiredInt(map, 'setIndex', path, min: 1, max: 999);
    final completedAt = requiredDateTime(map, 'completedAt', path);

    final weight = optionalDouble(map, 'weight', path, min: 0, max: 1000);
    final reps = optionalInt(map, 'reps', path, min: 0, max: 1000);
    final durationSeconds = optionalInt(
      map,
      'durationSeconds',
      path,
      min: 0,
      max: 7200,
    );
    final rir = optionalInt(map, 'rir', path, min: 0, max: 10);
    final restSeconds = optionalInt(
      map,
      'restSeconds',
      path,
      min: 0,
      max: 3600,
    );
    final isCompleted = optionalBool(map, 'isCompleted', path) ?? true;

    if (exerciseName == null ||
        bodyPart == null ||
        blockLabel == null ||
        itemOrder == null ||
        setIndex == null ||
        completedAt == null) {
      return null;
    }
    return SetLogDraft(
      exerciseName: exerciseName,
      bodyPart: bodyPart,
      blockLabel: blockLabel,
      itemOrder: itemOrder,
      setIndex: setIndex,
      weight: weight,
      reps: reps,
      durationSeconds: durationSeconds,
      rir: rir,
      restSeconds: restSeconds,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }
}
