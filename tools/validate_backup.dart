// Validates a record backup file before it goes anywhere near the phone.
//
//   dart run tools/validate_backup.dart <파일.json>
//
// Runs the *same* codec the app uses (`lib/data/exchange/backup_codec.dart`),
// so a file that passes here restores cleanly. Prints what it holds afterwards
// — the counts are what you check against the phone you exported from.
//
// Format spec: docs/07-BACKUP.md

import 'dart:io';

import 'package:workout_log/core/error/failure.dart';
import 'package:workout_log/core/result/result.dart';
import 'package:workout_log/data/exchange/backup_codec.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/domain/entity/backup_package.dart';

const _codec = BackupCodec(RoutineCodec());

Future<void> main(List<String> args) async {
  if (args.length != 1 || args.first == '-h' || args.first == '--help') {
    stdout.writeln('사용법: dart run tools/validate_backup.dart <파일.json>');
    exit(args.isEmpty ? 64 : 0);
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('✗ 파일이 없습니다: ${file.path}');
    exit(66);
  }

  final result = _codec.decode(await file.readAsString());
  switch (result) {
    case Err(:final failure):
      _printFailure(file.path, failure);
      exit(1);
    case Ok(:final value):
      _printSummary(file.path, await file.length(), value);
      exit(0);
  }
}

void _printFailure(String path, Failure failure) {
  stderr.writeln('✗ $path');
  stderr.writeln('  ${failure.message}');
  if (failure is RoutineFormatFailure) {
    for (final error in failure.errors) {
      stderr.writeln('  · $error');
    }
  }
}

void _printSummary(String path, int bytes, BackupParseResult parsed) {
  final package = parsed.package;
  final summary = package.summary;

  stdout.writeln('✓ $path  (${(bytes / 1024).toStringAsFixed(0)}KB)');
  stdout.writeln();
  stdout.writeln(
    '  운동 ${summary.sessionCount}회 · 세트 ${summary.setCount}개 · '
    '루틴 ${summary.routineCount}개 · 종목 ${summary.exerciseCount}개',
  );
  if (summary.firstSessionDate != null) {
    stdout.writeln(
      '  ${_day(summary.firstSessionDate!)} ~ ${_day(summary.lastSessionDate!)}',
    );
  }

  if (package.routines.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('  루틴');
    for (final routine in package.routines) {
      final body = routine.package;
      stdout.writeln(
        '    ${_pad(body.name, 22)}'
        'DAY ${body.dayCount}개 · ${body.totalSets}세트'
        '${routine.isActive ? '  (사용 중)' : ''}',
      );
    }
  }

  // Sets per body part across the whole file — the shape of the training, not
  // one week of it.
  final volume = <String, int>{};
  for (final session in package.sessions) {
    for (final set in session.sets) {
      if (!set.isCompleted) continue;
      volume.update(
        set.bodyPart.label,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
  }
  if (volume.isNotEmpty) {
    final entries = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    stdout.writeln();
    stdout.writeln('  기록된 세트 — 부위별');
    for (final entry in entries) {
      stdout.writeln(
        '    ${_pad(entry.key, 5)}${entry.value.toString().padLeft(5)}',
      );
    }
  }

  if (parsed.warnings.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('  경고 — 복원은 되지만 확인해 보세요');
    for (final warning in parsed.warnings) {
      stdout.writeln('  · $warning');
    }
  }
}

String _day(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}'
    '.${value.day.toString().padLeft(2, '0')}';

/// Pads to [width] counting CJK characters as two columns, so the table lines
/// up in a terminal.
String _pad(String value, int width) {
  var columns = 0;
  for (final rune in value.runes) {
    columns += _isWide(rune) ? 2 : 1;
  }
  return value + ' ' * (columns >= width ? 1 : width - columns);
}

bool _isWide(int rune) =>
    (rune >= 0x1100 && rune <= 0x115F) ||
    (rune >= 0x2E80 && rune <= 0xA4CF) ||
    (rune >= 0xAC00 && rune <= 0xD7A3) ||
    (rune >= 0xF900 && rune <= 0xFAFF) ||
    (rune >= 0xFE30 && rune <= 0xFE6F) ||
    (rune >= 0xFF00 && rune <= 0xFF60) ||
    (rune >= 0xFFE0 && rune <= 0xFFE6);
