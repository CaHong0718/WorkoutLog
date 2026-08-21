import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'json_file_io.dart';

/// Catches `.json` files shared into the app from elsewhere — 드라이브, 카톡,
/// 파일 관리자 — for both a cold start and a share that arrives while the app
/// is already open.
///
/// Both file kinds come through here; the listener reads
/// [PickedJsonFile.format] to decide which screen opens.
///
/// Every call is guarded. This is scaffolding *around* the app: if the plugin
/// is missing (test host) or the intent is malformed, the app must still
/// start normally.
@lazySingleton
class SharedFileReceiver {
  SharedFileReceiver(this._fileIo);

  final JsonFileIo _fileIo;

  final StreamController<PickedJsonFile> _incoming =
      StreamController<PickedJsonFile>.broadcast();

  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _started = false;

  /// Files handed to the app by another app.
  Stream<PickedJsonFile> get incoming => _incoming.stream;

  /// Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        _handle,
        onError: (Object error) =>
            debugPrint('SharedFileReceiver: stream failed: $error'),
      );
      // A share that launched the app is not replayed on the stream.
      await _handle(await ReceiveSharingIntent.instance.getInitialMedia());
    } catch (error, stackTrace) {
      debugPrint('SharedFileReceiver.start failed: $error\n$stackTrace');
    }
  }

  Future<void> _handle(List<SharedMediaFile> media) async {
    if (media.isEmpty) return;

    try {
      for (final item in media) {
        if (item.type != SharedMediaType.file) continue;
        // The larger limit: a share could be either kind, and the codec is a
        // better place to reject the wrong one than a size check is.
        final file = await _fileIo.readFile(
          File(item.path),
          maxBytes: JsonFileIo.backupMaxBytes,
        );
        if (file == null) continue;
        _incoming.add(file);
        // One file per share: each screen handles a single preview, and
        // queueing several would stack sheets on top of each other.
        break;
      }
    } catch (error, stackTrace) {
      debugPrint('SharedFileReceiver: read failed: $error\n$stackTrace');
    } finally {
      // Mark the intent consumed, so coming back to the app later does not
      // reopen the same file.
      try {
        await ReceiveSharingIntent.instance.reset();
      } catch (_) {
        // Nothing to do — worst case the file is offered twice.
      }
    }
  }

  @disposeMethod
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _incoming.close();
  }
}
