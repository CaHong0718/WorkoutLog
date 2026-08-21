/// Shared primitives for the two exchange formats — routines
/// (`docs/04-ROUTINE-EXCHANGE.md`) and backups (`docs/07-BACKUP.md`).
///
/// Both readers follow the same rule: **collect every problem instead of
/// throwing on the first one.** A hand-written file usually has more than one
/// typo, and fixing them one round-trip at a time is miserable. Every message
/// carries its path inside the document, so `routines[2].days[0].blocks[1]`
/// points at exactly one place.
///
/// Depends on nothing but `dart:core`: `tools/validate_routine.dart` and
/// `tools/validate_backup.dart` run these classes from the command line, so a
/// file that validates there imports cleanly on the phone.
abstract class JsonReader {
  final List<String> errors = [];

  /// Problems the reader recovered from. Never block an import.
  final List<String> warnings = [];

  /// `sessions[3].sets[11].setIndex` — and just `sessions` at the root, where
  /// [path] is empty.
  String _at(String path, String key) => path.isEmpty ? key : '$path.$key';

  Map<String, Object?>? object(Object? value, String path) {
    if (value is Map<String, Object?>) return value;
    errors.add('$path: 객체여야 합니다 (${jsonDisplay(value)})');
    return null;
  }

  List<Object?>? requiredList(
    Map<String, Object?> map,
    String key,
    String path, {
    int minLength = 0,
  }) {
    final value = map[key];
    if (value is! List) {
      errors.add('${_at(path, key)}: 배열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    if (value.length < minLength) {
      errors.add('${_at(path, key)}: $minLength개 이상 필요합니다 (${value.length}개)');
      return null;
    }
    return value;
  }

  List<Object?> optionalList(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    final value = map[key];
    if (value == null) return const [];
    if (value is! List) {
      errors.add('${_at(path, key)}: 배열이어야 합니다 (${jsonDisplay(value)})');
      return const [];
    }
    return value;
  }

  String? requiredString(
    Map<String, Object?> map,
    String key,
    String path, {
    required int maxLength,
  }) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      errors.add('${_at(path, key)}: 비어 있지 않은 문자열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.length > maxLength) {
      errors.add('${_at(path, key)}: $maxLength자 이하여야 합니다 (${trimmed.length}자)');
      return null;
    }
    return trimmed;
  }

  String? optionalString(Map<String, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String) {
      errors.add('${_at(path, key)}: 문자열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    return jsonTrimmed(value);
  }

  int? requiredInt(
    Map<String, Object?> map,
    String key,
    String path, {
    required int min,
    required int max,
  }) {
    final value = jsonInteger(map[key]);
    if (value == null) {
      errors.add('${_at(path, key)}: 정수여야 합니다 (${jsonDisplay(map[key])})');
      return null;
    }
    if (value < min || value > max) {
      errors.add('${_at(path, key)}: $min–$max 범위여야 합니다 ($value)');
      return null;
    }
    return value;
  }

  int? optionalInt(
    Map<String, Object?> map,
    String key,
    String path, {
    required int min,
    required int max,
  }) {
    if (map[key] == null) return null;
    return requiredInt(map, key, path, min: min, max: max);
  }

  /// Accepts `60` and `60.5` alike — weights are the only fractional value in
  /// either format.
  double? optionalDouble(
    Map<String, Object?> map,
    String key,
    String path, {
    required double min,
    required double max,
  }) {
    final raw = map[key];
    if (raw == null) return null;
    final value = raw is int
        ? raw.toDouble()
        : raw is double
        ? raw
        : null;
    if (value == null || value.isNaN || value.isInfinite) {
      errors.add('${_at(path, key)}: 숫자여야 합니다 (${jsonDisplay(raw)})');
      return null;
    }
    if (value < min || value > max) {
      errors.add('${_at(path, key)}: $min–$max 범위여야 합니다 ($value)');
      return null;
    }
    return value;
  }

  bool? optionalBool(Map<String, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) return null;
    if (value is! bool) {
      errors.add('${_at(path, key)}: true 또는 false여야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    return value;
  }

  /// An ISO 8601 instant. Kept in local time — every date in this app is a
  /// wall-clock date, and `DateTime.parse` preserves that when no zone suffix
  /// is written.
  DateTime? requiredDateTime(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    final value = map[key];
    if (value is! String) {
      errors.add('${_at(path, key)}: ISO8601 문자열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      errors.add('${_at(path, key)}: ISO8601 날짜여야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  DateTime? optionalDateTime(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    if (map[key] == null) return null;
    return requiredDateTime(map, key, path);
  }

  /// A calendar day (`yyyy-MM-dd`), read as local midnight.
  ///
  /// Deliberately not an instant: a session's `date` is the key the calendar
  /// groups on, and carrying a time would shift the day when the file is
  /// restored in another time zone.
  DateTime? requiredDate(Map<String, Object?> map, String key, String path) {
    final value = map[key];
    if (value is! String) {
      errors.add('${_at(path, key)}: "yyyy-MM-dd" 문자열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})',
    ).firstMatch(value.trim());
    if (match == null) {
      errors.add('${_at(path, key)}: "yyyy-MM-dd" 형식이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      errors.add('${_at(path, key)}: 실제 날짜가 아닙니다 (${jsonDisplay(value)})');
      return null;
    }
    return DateTime(year, month, day);
  }

  T? requiredEnum<T>(
    Map<String, Object?> map,
    String key,
    String path,
    List<T> values,
    String Function(T) nameOf,
  ) {
    final value = map[key];
    if (value is! String) {
      errors.add('${_at(path, key)}: 문자열이어야 합니다 (${jsonDisplay(value)})');
      return null;
    }
    final match = enumByName(values, value, nameOf);
    if (match == null) {
      errors.add(
        '${_at(path, key)}: 알 수 없는 값 "$value" — '
        '${values.map(nameOf).join(" · ")} 중 하나여야 합니다',
      );
      return null;
    }
    return match;
  }

  T? optionalEnum<T>(
    Map<String, Object?> map,
    String key,
    String path,
    List<T> values,
    String Function(T) nameOf,
  ) {
    if (map[key] == null) return null;
    return requiredEnum(map, key, path, values, nameOf);
  }
}

// ── free helpers ──────────────────────────────────────────────────────────

List<Object?> jsonList(Object? value) => value is List ? value : const [];

/// Accepts `40` and `40.0` alike; JSON writers disagree about whole numbers.
int? jsonInteger(Object? value) {
  if (value is int) return value;
  if (value is double && value == value.roundToDouble()) return value.toInt();
  return null;
}

String? jsonTrimmed(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Never falls back to a default — an unknown enum value is an error, so that
/// a `legs` → `leg` typo is reported instead of silently becoming abs.
T? enumByName<T>(List<T> values, String name, String Function(T) nameOf) {
  final needle = name.trim();
  for (final value in values) {
    if (nameOf(value) == needle) return value;
  }
  return null;
}

/// How a wrong value is quoted back to the user.
String jsonDisplay(Object? value) {
  if (value == null) return '없음';
  if (value is Map) return '객체';
  if (value is List) return '배열';
  if (value is String) {
    final text = value.length > 30 ? '${value.substring(0, 30)}…' : value;
    return '"$text"';
  }
  return '$value';
}

/// `2026-08-18` — the wire form of a calendar day.
String jsonDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}'
    '-${value.month.toString().padLeft(2, '0')}'
    '-${value.day.toString().padLeft(2, '0')}';
