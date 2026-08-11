// Validates a routine exchange file before it goes anywhere near the phone.
//
//   dart run tools/validate_routine.dart <파일.json>
//
// Runs the *same* codec the app uses (`lib/data/exchange/routine_codec.dart`),
// so a file that passes here imports cleanly. Prints the day/volume summary
// afterwards — the numbers are what you check against the original plan.
//
// Format spec: docs/04-ROUTINE-EXCHANGE.md

import 'dart:io';

import 'package:workout_log/core/error/failure.dart';
import 'package:workout_log/core/result/result.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/domain/entity/routine_package.dart';

const _codec = RoutineCodec();

Future<void> main(List<String> args) async {
  if (args.length != 1 || args.first == '-h' || args.first == '--help') {
    stdout.writeln('사용법: dart run tools/validate_routine.dart <파일.json>');
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
      _printSummary(file.path, value);
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

void _printSummary(String path, RoutineParseResult parsed) {
  final package = parsed.package;

  stdout.writeln('✓ $path');
  stdout.writeln();
  stdout.writeln('  ${package.name}');
  if (package.description != null) {
    stdout.writeln('  ${package.description}');
  }
  stdout.writeln(
    '  DAY ${package.dayCount}개 · 총 ${package.totalSets}세트 · '
    '1회 ${package.sessionMinutes}분',
  );

  stdout.writeln();
  for (final day in package.days) {
    final blocks = day.blocks.length;
    stdout.writeln(
      '  ${_pad('DAY ${day.code}', 8)}${_pad(day.title, 22)}'
      '${_pad(day.primaryBodyPart.label, 5)}'
      '$blocks블록 · ${day.totalSets}세트 · ${day.estimatedMinutes}분',
    );
  }

  final volume = package.volumeByBodyPart.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (volume.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('  주간 볼륨');
    for (final entry in volume) {
      stdout.writeln(
        '    ${_pad(entry.key.label, 5)}'
        '${entry.value.toString().padLeft(3)}  ${'█' * entry.value}',
      );
    }
  }

  stdout.writeln();
  stdout.writeln('  종목 ${package.exercises.length}개');

  if (parsed.warnings.isNotEmpty) {
    stdout.writeln();
    stdout.writeln('  경고 — 가져오기는 되지만 확인해 보세요');
    for (final warning in parsed.warnings) {
      stdout.writeln('  · $warning');
    }
  }
}

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
