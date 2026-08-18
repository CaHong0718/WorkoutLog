import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../core/result/result.dart';
import '../../domain/entity/enums.dart';
import '../../domain/entity/routine_package.dart';
import '../../domain/repository/routine_exchange.dart';

/// Reads and writes `docs/04-ROUTINE-EXCHANGE.md` documents.
///
/// Deliberately depends on nothing but `dart:convert` and the domain:
/// `tools/validate_routine.dart` runs this exact class from the command line,
/// so a file that validates there imports cleanly on the phone.
@LazySingleton(as: RoutineExchange)
class RoutineCodec implements RoutineExchange {
  const RoutineCodec();

  static const String formatId = 'workout-log.routine';
  static const int formatVersion = 1;

  @override
  Result<RoutineParseResult> decode(String source) {
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

    final decoder = _Decoder();
    final package = decoder.read(root);
    if (package == null || decoder.errors.isNotEmpty) {
      return Err(
        RoutineFormatFailure('루틴 파일 형식이 올바르지 않습니다.', errors: decoder.errors),
      );
    }
    return Ok(
      RoutineParseResult(
        package: package,
        warnings: decoder.warnings.toSet().toList(),
      ),
    );
  }

  @override
  String encode(RoutinePackage package, {DateTime? exportedAt}) {
    final document = <String, Object?>{
      'format': formatId,
      'version': formatVersion,
      if (exportedAt != null) 'exportedAt': exportedAt.toIso8601String(),
      'routine': <String, Object?>{
        'name': package.name,
        if (package.description != null) 'description': package.description,
        'sessionMinutes': package.sessionMinutes,
        'days': [for (final day in package.days) _dayJson(day)],
      },
    };
    return const JsonEncoder.withIndent('  ').convert(document);
  }

  @override
  String fileNameFor(RoutinePackage package, DateTime now) {
    final safe = package.name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return '${safe.isEmpty ? 'routine' : safe}_$stamp.json';
  }

  // ── encode helpers ──────────────────────────────────────────────────────
  //
  // Null and default-valued keys are omitted: the file stays short enough to
  // read and hand-edit, which is the whole point of the format.

  Map<String, Object?> _dayJson(RoutineDayDraft day) => <String, Object?>{
    'code': day.code,
    'title': day.title,
    if (day.subtitle != null) 'subtitle': day.subtitle,
    if (day.description != null) 'description': day.description,
    'primaryBodyPart': day.primaryBodyPart.name,
    'blocks': [for (final block in day.blocks) _blockJson(block)],
  };

  Map<String, Object?> _blockJson(RoutineBlockDraft block) => <String, Object?>{
    'label': block.label,
    if (block.name != null) 'name': block.name,
    if (block.isSuperset) 'type': block.type.name,
    if (block.isSuperset) 'rounds': block.rounds,
    'restSeconds': block.restSeconds,
    if (block.targetMinutes != null) 'targetMinutes': block.targetMinutes,
    if (!block.isCuttable) 'isCuttable': false,
    'items': [for (final item in block.items) _itemJson(item)],
  };

  Map<String, Object?> _itemJson(RoutineItemDraft item) => <String, Object?>{
    'exercise': <String, Object?>{
      'name': item.exercise.name,
      'bodyPart': item.exercise.bodyPart.name,
      if (item.exercise.subTarget != null) 'subTarget': item.exercise.subTarget,
      if (item.exercise.equipment != null) 'equipment': item.exercise.equipment,
    },
    'sets': item.sets,
    'repMode': item.repMode.name,
    if (item.repMin != null) 'repMin': item.repMin,
    if (item.repMax != null) 'repMax': item.repMax,
    if (item.durationSeconds != null) 'durationSeconds': item.durationSeconds,
    if (item.restSecondsOverride != null)
      'restSecondsOverride': item.restSecondsOverride,
    if (item.targetRir != null) 'targetRir': item.targetRir,
    if (item.note != null) 'note': item.note,
    if (item.alternativeNames.isNotEmpty) 'alternatives': item.alternativeNames,
  };
}

// ── decoding ──────────────────────────────────────────────────────────────

/// Collects *every* problem instead of throwing on the first one — a
/// hand-written routine usually has more than one typo, and fixing them one
/// round-trip at a time is miserable.
class _Decoder {
  final List<String> errors = [];
  final List<String> warnings = [];

  /// Exercise definitions found anywhere in the file, keyed by name. Filled
  /// before the main pass so `"exercise": "랫 풀다운"` resolves even when the
  /// full definition appears later.
  final Map<String, ExerciseDraft> _defined = {};

  RoutinePackage? read(Object? root) {
    final document = _object(root, '루트');
    if (document == null) return null;

    final format = document['format'];
    if (format != RoutineCodec.formatId) {
      errors.add(
        'format: "${RoutineCodec.formatId}"이어야 합니다 (${_display(format)}). '
        '루틴 파일이 맞는지 확인하세요.',
      );
    }

    final version = _integer(document['version']);
    if (version == null) {
      errors.add('version: 정수여야 합니다 (${_display(document['version'])})');
    } else if (version != RoutineCodec.formatVersion) {
      errors.add(
        'version: 이 앱은 ${RoutineCodec.formatVersion}만 읽을 수 있습니다 ($version)',
      );
    }

    final routine = _object(document['routine'], 'routine');
    if (routine == null) return null;

    _collectExercises(routine);

    final name = _requiredString(routine, 'name', 'routine', maxLength: 120);
    final description = _optionalString(routine, 'description', 'routine');
    final sessionMinutes =
        _optionalInt(routine, 'sessionMinutes', 'routine', min: 1, max: 600) ??
        RoutinePackage.defaultSessionMinutes;

    final rawDays = _requiredList(routine, 'days', 'routine', minLength: 1);
    final days = <RoutineDayDraft>[];
    for (var i = 0; i < (rawDays?.length ?? 0); i++) {
      final day = _readDay(rawDays![i], 'routine.days[$i]');
      if (day != null) days.add(day);
    }

    if (name == null || errors.isNotEmpty) return null;
    return RoutinePackage(
      name: name,
      description: description,
      sessionMinutes: sessionMinutes,
      days: days,
    );
  }

  /// Pre-pass: index every object-form exercise so bare-string references can
  /// be resolved regardless of where they appear. Reports nothing — the main
  /// pass is responsible for errors.
  void _collectExercises(Map<String, Object?> routine) {
    for (final day in _asList(routine['days'])) {
      if (day is! Map<String, Object?>) continue;
      for (final block in _asList(day['blocks'])) {
        if (block is! Map<String, Object?>) continue;
        for (final item in _asList(block['items'])) {
          if (item is! Map<String, Object?>) continue;
          final raw = item['exercise'];
          if (raw is! Map<String, Object?>) continue;

          final name = raw['name'];
          final part = raw['bodyPart'];
          if (name is! String || name.trim().isEmpty) continue;
          if (part is! String) continue;
          final bodyPart = _lookup(BodyPart.values, part, (e) => e.name);
          if (bodyPart == null) continue;

          final draft = ExerciseDraft(
            name: name.trim(),
            bodyPart: bodyPart,
            subTarget: _trimmed(raw['subTarget']),
            equipment: _trimmed(raw['equipment']),
          );
          final existing = _defined[draft.name];
          if (existing == null) {
            _defined[draft.name] = draft;
          } else if (existing.bodyPart != draft.bodyPart) {
            warnings.add(
              '종목 "${draft.name}"의 부위가 파일 안에서 엇갈립니다. '
              '먼저 나온 ${existing.bodyPart.label}로 통일했습니다.',
            );
          }
        }
      }
    }
  }

  RoutineDayDraft? _readDay(Object? value, String path) {
    final map = _object(value, path);
    if (map == null) return null;

    final code = _requiredString(map, 'code', path, maxLength: 8);
    final title = _requiredString(map, 'title', path, maxLength: 120);
    final bodyPart = _requiredEnum(
      map,
      'primaryBodyPart',
      path,
      BodyPart.values,
      (e) => e.name,
    );

    final blocks = <RoutineBlockDraft>[];
    final rawBlocks = _optionalList(map, 'blocks', path);
    for (var i = 0; i < rawBlocks.length; i++) {
      final block = _readBlock(rawBlocks[i], '$path.blocks[$i]');
      if (block != null) blocks.add(block);
    }

    if (code == null || title == null || bodyPart == null) return null;
    return RoutineDayDraft(
      code: code,
      title: title,
      subtitle: _optionalString(map, 'subtitle', path),
      description: _optionalString(map, 'description', path),
      primaryBodyPart: bodyPart,
      blocks: blocks,
    );
  }

  RoutineBlockDraft? _readBlock(Object? value, String path) {
    final map = _object(value, path);
    if (map == null) return null;

    final label = _requiredString(map, 'label', path, maxLength: 20);
    final type =
        _optionalEnum(map, 'type', path, BlockType.values, (e) => e.name) ??
        BlockType.straight;
    final rounds = _optionalInt(map, 'rounds', path, min: 1, max: 50) ?? 1;
    final restSeconds = _requiredInt(
      map,
      'restSeconds',
      path,
      min: 0,
      max: 3600,
    );

    final items = <RoutineItemDraft>[];
    final rawItems = _optionalList(map, 'items', path);
    for (var i = 0; i < rawItems.length; i++) {
      final item = _readItem(rawItems[i], '$path.items[$i]');
      if (item != null) items.add(item);
    }

    if (label == null || restSeconds == null) return null;

    final isSuperset = type == BlockType.superset;
    return RoutineBlockDraft(
      label: label,
      name: _optionalString(map, 'name', path),
      type: type,
      rounds: isSuperset ? rounds : 1,
      restSeconds: restSeconds,
      targetMinutes: _optionalInt(map, 'targetMinutes', path, min: 1, max: 600),
      isCuttable: _optionalBool(map, 'isCuttable', path) ?? true,
      items: isSuperset ? _alignRounds(items, rounds, label, path) : items,
    );
  }

  /// A superset round runs every item once, so the item set counts have to
  /// equal the block's round count. Correct rather than reject: the intent is
  /// unambiguous and rejecting would block the whole import.
  List<RoutineItemDraft> _alignRounds(
    List<RoutineItemDraft> items,
    int rounds,
    String label,
    String path,
  ) {
    final aligned = <RoutineItemDraft>[];
    for (final item in items) {
      if (item.sets == rounds) {
        aligned.add(item);
        continue;
      }
      warnings.add(
        '$path: 슈퍼세트 "$label"의 ${item.exercise.name} 세트 수 ${item.sets}를 '
        '라운드 수 $rounds에 맞췄습니다.',
      );
      aligned.add(item.copyWith(sets: rounds));
    }
    return aligned;
  }

  RoutineItemDraft? _readItem(Object? value, String path) {
    final map = _object(value, path);
    if (map == null) return null;

    final exercise = _readExercise(map['exercise'], '$path.exercise');
    final sets = _requiredInt(map, 'sets', path, min: 1, max: 50);
    final repMode =
        _optionalEnum(map, 'repMode', path, RepMode.values, (e) => e.name) ??
        RepMode.range;

    int? repMin;
    int? repMax;
    int? durationSeconds;

    switch (repMode) {
      case RepMode.range:
        final min = _optionalInt(map, 'repMin', path, min: 1, max: 200);
        final max = _optionalInt(map, 'repMax', path, min: 1, max: 200);
        if (min == null && max == null) {
          errors.add('$path: repMode "range"에는 repMin·repMax가 필요합니다.');
        } else {
          // One bound is enough for a fixed prescription such as `4 × 10`.
          repMin = min ?? max;
          repMax = max ?? min;
          if (repMax! < repMin!) {
            errors.add('$path.repMax: repMin($repMin)보다 작습니다 ($repMax)');
          }
        }
      case RepMode.amrap:
        break;
      case RepMode.duration:
        durationSeconds = _requiredInt(
          map,
          'durationSeconds',
          path,
          min: 1,
          max: 7200,
        );
        if (durationSeconds == null) {
          errors.add('$path: repMode "duration"에는 durationSeconds가 필요합니다.');
        }
    }

    final alternatives = _readAlternatives(map, path);

    if (exercise == null || sets == null) return null;
    return RoutineItemDraft(
      exercise: exercise,
      sets: sets,
      repMode: repMode,
      repMin: repMin,
      repMax: repMax,
      durationSeconds: durationSeconds,
      restSecondsOverride: _optionalInt(
        map,
        'restSecondsOverride',
        path,
        min: 0,
        max: 3600,
      ),
      targetRir: _optionalInt(map, 'targetRir', path, min: 0, max: 10),
      note: _optionalString(map, 'note', path),
      alternativeNames: alternatives,
    );
  }

  ExerciseDraft? _readExercise(Object? value, String path) {
    if (value is String) {
      final name = value.trim();
      if (name.isEmpty) {
        errors.add('$path: 종목 이름이 비어 있습니다.');
        return null;
      }
      final defined = _defined[name];
      if (defined == null) {
        errors.add(
          '$path: "$name"의 bodyPart를 알 수 없습니다. 파일 안에서 한 번은 '
          '{"name": "$name", "bodyPart": …} 형태로 정의하세요.',
        );
        return null;
      }
      return defined;
    }

    final map = _object(value, path);
    if (map == null) return null;

    final name = _requiredString(map, 'name', path, maxLength: 120);
    final bodyPart = _requiredEnum(
      map,
      'bodyPart',
      path,
      BodyPart.values,
      (e) => e.name,
    );
    if (name == null || bodyPart == null) return null;

    // The pre-pass already picked a winner for duplicated names; reuse it so
    // one name always yields one draft.
    return _defined[name] ??
        ExerciseDraft(
          name: name,
          bodyPart: bodyPart,
          subTarget: _optionalString(map, 'subTarget', path),
          equipment: _optionalString(map, 'equipment', path),
        );
  }

  List<String> _readAlternatives(Map<String, Object?> map, String path) {
    final raw = map['alternatives'];
    if (raw == null) return const [];
    if (raw is! List) {
      errors.add('$path.alternatives: 배열이어야 합니다 (${_display(raw)})');
      return const [];
    }

    final names = <String>[];
    for (var i = 0; i < raw.length; i++) {
      final entry = raw[i];
      if (entry is String && entry.trim().isNotEmpty) {
        names.add(entry.trim());
      } else {
        errors.add(
          '$path.alternatives[$i]: 종목 이름 문자열이어야 합니다 (${_display(entry)})',
        );
      }
    }
    return names;
  }

  // ── primitives ────────────────────────────────────────────────────────────

  Map<String, Object?>? _object(Object? value, String path) {
    if (value is Map<String, Object?>) return value;
    errors.add('$path: 객체여야 합니다 (${_display(value)})');
    return null;
  }

  List<Object?>? _requiredList(
    Map<String, Object?> map,
    String key,
    String path, {
    int minLength = 0,
  }) {
    final value = map[key];
    if (value is! List) {
      errors.add('$path.$key: 배열이어야 합니다 (${_display(value)})');
      return null;
    }
    if (value.length < minLength) {
      errors.add('$path.$key: $minLength개 이상 필요합니다 (${value.length}개)');
      return null;
    }
    return value;
  }

  List<Object?> _optionalList(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    final value = map[key];
    if (value == null) return const [];
    if (value is! List) {
      errors.add('$path.$key: 배열이어야 합니다 (${_display(value)})');
      return const [];
    }
    return value;
  }

  String? _requiredString(
    Map<String, Object?> map,
    String key,
    String path, {
    required int maxLength,
  }) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      errors.add('$path.$key: 비어 있지 않은 문자열이어야 합니다 (${_display(value)})');
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.length > maxLength) {
      errors.add('$path.$key: $maxLength자 이하여야 합니다 (${trimmed.length}자)');
      return null;
    }
    return trimmed;
  }

  String? _optionalString(Map<String, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String) {
      errors.add('$path.$key: 문자열이어야 합니다 (${_display(value)})');
      return null;
    }
    return _trimmed(value);
  }

  int? _requiredInt(
    Map<String, Object?> map,
    String key,
    String path, {
    required int min,
    required int max,
  }) {
    final value = _integer(map[key]);
    if (value == null) {
      errors.add('$path.$key: 정수여야 합니다 (${_display(map[key])})');
      return null;
    }
    if (value < min || value > max) {
      errors.add('$path.$key: $min–$max 범위여야 합니다 ($value)');
      return null;
    }
    return value;
  }

  int? _optionalInt(
    Map<String, Object?> map,
    String key,
    String path, {
    required int min,
    required int max,
  }) {
    if (map[key] == null) return null;
    return _requiredInt(map, key, path, min: min, max: max);
  }

  bool? _optionalBool(Map<String, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) return null;
    if (value is! bool) {
      errors.add('$path.$key: true 또는 false여야 합니다 (${_display(value)})');
      return null;
    }
    return value;
  }

  T? _requiredEnum<T>(
    Map<String, Object?> map,
    String key,
    String path,
    List<T> values,
    String Function(T) nameOf,
  ) {
    final value = map[key];
    if (value is! String) {
      errors.add('$path.$key: 문자열이어야 합니다 (${_display(value)})');
      return null;
    }
    final match = _lookup(values, value, nameOf);
    if (match == null) {
      errors.add(
        '$path.$key: 알 수 없는 값 "$value" — '
        '${values.map(nameOf).join(" · ")} 중 하나여야 합니다',
      );
      return null;
    }
    return match;
  }

  T? _optionalEnum<T>(
    Map<String, Object?> map,
    String key,
    String path,
    List<T> values,
    String Function(T) nameOf,
  ) {
    if (map[key] == null) return null;
    return _requiredEnum(map, key, path, values, nameOf);
  }
}

// ── free helpers ──────────────────────────────────────────────────────────

List<Object?> _asList(Object? value) => value is List ? value : const [];

/// Accepts `40` and `40.0` alike; JSON writers disagree about whole numbers.
int? _integer(Object? value) {
  if (value is int) return value;
  if (value is double && value == value.roundToDouble()) return value.toInt();
  return null;
}

String? _trimmed(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

T? _lookup<T>(List<T> values, String name, String Function(T) nameOf) {
  final needle = name.trim();
  for (final value in values) {
    if (nameOf(value) == needle) return value;
  }
  return null;
}

String _display(Object? value) {
  if (value == null) return '없음';
  if (value is Map) return '객체';
  if (value is List) return '배열';
  if (value is String) {
    final text = value.length > 30 ? '${value.substring(0, 30)}…' : value;
    return '"$text"';
  }
  return '$value';
}
