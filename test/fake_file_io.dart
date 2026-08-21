import 'dart:io';

import 'package:workout_log/core/platform/json_file_io.dart';

/// Stands in for the system file picker and share sheet.
///
/// The only fake in these tests: everything below it — bloc, use case,
/// repository, Drift — is the real thing on an in-memory database. A platform
/// dialog is the one thing a test host cannot open.
class FakeFileIo implements JsonFileIo {
  PickedJsonFile? nextPick;
  bool shareSucceeds = true;

  String? sharedFileName;
  String? sharedContents;

  @override
  Future<PickedJsonFile?> pickJsonFile({int maxBytes = 0}) async => nextPick;

  @override
  Future<PickedJsonFile?> readFile(File file, {int maxBytes = 0}) async =>
      nextPick;

  @override
  Future<bool> shareJsonFile({
    required String fileName,
    required String contents,
  }) async {
    sharedFileName = fileName;
    sharedContents = contents;
    return shareSucceeds;
  }
}
