import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

/// Moves routine `.json` files between the app and the rest of the phone.
///
/// Every platform call is wrapped: a missing plugin (test host), a denied
/// picker or a share sheet the user backs out of must all degrade to "nothing
/// happened" rather than take the screen down — the same rule `RestNotifier`
/// follows.
@lazySingleton
class RoutineFileIo {
  const RoutineFileIo();

  /// A routine file is a few tens of kilobytes. Anything far past that was
  /// picked by mistake, and reading it whole would be the expensive way to
  /// find out.
  static const int maxBytes = 4 * 1024 * 1024;

  /// Opens the system picker and reads the chosen file.
  ///
  /// Returns null when the user cancels or the file cannot be read. The
  /// extension is deliberately *not* filtered — a `.json` served as
  /// `text/plain` would become unselectable, and a wrong pick already fails
  /// with a readable message from the codec.
  Future<PickedRoutineFile?> pickRoutineFile() async {
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
      return readFile(File(path));
    } catch (error, stackTrace) {
      debugPrint('RoutineFileIo.pickRoutineFile failed: $error\n$stackTrace');
      return null;
    }
  }

  /// Reads a file that arrived from somewhere else — the picker, or a share
  /// from another app.
  Future<PickedRoutineFile?> readFile(File file) async {
    try {
      if (!file.existsSync()) return null;
      if (await file.length() > maxBytes) {
        debugPrint('RoutineFileIo.readFile: ${file.path} is too large');
        return null;
      }
      return PickedRoutineFile(
        fileName: _baseName(file.path),
        contents: await file.readAsString(),
      );
    } catch (error, stackTrace) {
      debugPrint('RoutineFileIo.readFile failed: $error\n$stackTrace');
      return null;
    }
  }

  /// Hands [contents] to the Android share sheet as [fileName].
  ///
  /// share_plus writes the bytes to its own cache directory, so no temporary
  /// file has to be managed here.
  Future<bool> shareRoutineFile({
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
      debugPrint('RoutineFileIo.shareRoutineFile failed: $error\n$stackTrace');
      return false;
    }
  }

  String _baseName(String path) {
    final index = path.lastIndexOf(RegExp(r'[/\\]'));
    return index < 0 ? path : path.substring(index + 1);
  }
}

class PickedRoutineFile {
  const PickedRoutineFile({required this.fileName, required this.contents});

  final String fileName;
  final String contents;
}
