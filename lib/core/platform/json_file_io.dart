import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

/// Moves the app's `.json` files — routines (`docs/04-ROUTINE-EXCHANGE.md`) and
/// record backups (`docs/07-BACKUP.md`) — between the app and the rest of the
/// phone.
///
/// Every platform call is wrapped: a missing plugin (test host), a denied
/// picker or a share sheet the user backs out of must all degrade to "nothing
/// happened" rather than take the screen down — the same rule `RestNotifier`
/// follows.
@lazySingleton
class JsonFileIo {
  const JsonFileIo();

  /// A routine file is a few tens of kilobytes. Anything far past that was
  /// picked by mistake, and reading it whole would be the expensive way to
  /// find out.
  static const int routineMaxBytes = 4 * 1024 * 1024;

  /// A backup carries every set ever logged, at roughly 150 bytes each — this
  /// is over ten years of training (`docs/07-BACKUP.md` §9).
  static const int backupMaxBytes = 16 * 1024 * 1024;

  /// Opens the system picker and reads the chosen file.
  ///
  /// Returns null when the user cancels or the file cannot be read. The
  /// extension is deliberately *not* filtered — a `.json` served as
  /// `text/plain` would become unselectable, and a wrong pick already fails
  /// with a readable message from the codec.
  Future<PickedJsonFile?> pickJsonFile({
    int maxBytes = routineMaxBytes,
  }) async {
    try {
      final path = await FlutterFileDialog.pickFile(
        params: const OpenFileDialogParams(
          mimeTypesFilter: [
            'application/json',
            'text/plain',
            'application/octet-stream',
          ],
        ),
      );
      if (path == null) return null;
      return readFile(File(path), maxBytes: maxBytes);
    } catch (error, stackTrace) {
      debugPrint('JsonFileIo.pickJsonFile failed: $error\n$stackTrace');
      return null;
    }
  }

  /// Reads a file that arrived from somewhere else — the picker, or a share
  /// from another app.
  Future<PickedJsonFile?> readFile(
    File file, {
    int maxBytes = routineMaxBytes,
  }) async {
    try {
      if (!file.existsSync()) return null;
      if (await file.length() > maxBytes) {
        debugPrint('JsonFileIo.readFile: ${file.path} is too large');
        return null;
      }
      return PickedJsonFile(
        fileName: _baseName(file.path),
        contents: await file.readAsString(),
      );
    } catch (error, stackTrace) {
      debugPrint('JsonFileIo.readFile failed: $error\n$stackTrace');
      return null;
    }
  }

  /// Hands [contents] to the system share sheet as [fileName].
  ///
  /// share_plus writes the bytes to its own cache directory, so no temporary
  /// file has to be managed here. No `sharePositionOrigin` is passed: the
  /// plugin anchors the iPad popover to the centre of the view when the rect
  /// is empty, and this app is laid out for a phone.
  Future<bool> shareJsonFile({
    required String fileName,
    required String contents,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(utf8.encode(contents)),
              mimeType: 'application/json',
              name: fileName,
            ),
          ],
          fileNameOverrides: [fileName],
          subject: fileName,
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (error, stackTrace) {
      debugPrint('JsonFileIo.shareJsonFile failed: $error\n$stackTrace');
      return false;
    }
  }

  String _baseName(String path) {
    final index = path.lastIndexOf(RegExp(r'[/\\]'));
    return index < 0 ? path : path.substring(index + 1);
  }
}

class PickedJsonFile {
  const PickedJsonFile({required this.fileName, required this.contents});

  final String fileName;
  final String contents;

  /// The document's `format` field, or null when the text is not a JSON object.
  ///
  /// Just enough to send a shared file to the right screen — a routine goes to
  /// the routine library, a backup to the backup screen. Real validation is
  /// still the codec's job, so anything unrecognised falls through to the
  /// routine importer and gets a proper error there.
  String? get format {
    try {
      final root = jsonDecode(contents);
      if (root is Map<String, Object?> && root['format'] is String) {
        return root['format']! as String;
      }
    } on FormatException {
      // Not JSON at all; let the codec say so.
    }
    return null;
  }
}
