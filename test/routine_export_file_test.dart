import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_log/data/database/app_database.dart';
import 'package:workout_log/data/exchange/routine_codec.dart';
import 'package:workout_log/data/repository/routine_repository_impl.dart';

/// Keeps `routines/무분할-40분.json` identical to what the seed produces.
///
/// That file has two jobs: it is the worked example every routine conversion
/// starts from (`.claude/skills/routine-file/SKILL.md`), and it is a restore
/// point if the copy on the phone gets edited into a corner. A seed change
/// that is not mirrored there quietly makes both wrong, so this test fails
/// until it is regenerated:
///
/// ```bash
/// UPDATE_ROUTINE_EXPORT=1 flutter test test/routine_export_file_test.dart
/// ```
void main() {
  final file = File('routines/무분할-40분.json');

  test('routines/무분할-40분.json이 시드 루틴과 일치한다', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = RoutineRepositoryImpl(db.routineDao, db);

    final routine = (await repository.getActiveRoutine()).valueOrNull!;
    final package = (await repository.exportRoutine(routine.id)).valueOrNull!;

    // No `exportedAt`: a timestamp would rewrite the file on every run.
    final expected = const RoutineCodec().encode(package);

    if (Platform.environment['UPDATE_ROUTINE_EXPORT'] == '1') {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(expected);
      return;
    }

    expect(
      file.existsSync(),
      isTrue,
      reason: '${file.path}이 없습니다. UPDATE_ROUTINE_EXPORT=1로 생성하세요.',
    );
    expect(
      _normalized(file.readAsStringSync()),
      _normalized(expected),
      reason:
          '시드가 바뀌었는데 ${file.path}이 그대로입니다. '
          'UPDATE_ROUTINE_EXPORT=1 flutter test test/routine_export_file_test.dart '
          '로 다시 생성하세요.',
    );
  });
}

/// Git may check the file out with CRLF on Windows; the comparison is about
/// content, not line endings.
String _normalized(String source) => source.replaceAll('\r\n', '\n');
