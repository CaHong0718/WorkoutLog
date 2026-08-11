import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'routine_file_io.dart';

/// Catches routine files shared into the app from elsewhere — 드라이브, 카톡,
/// 파일 관리자 — for both a cold start and a share that arrives while the app
/// is already open.
///
/// Every call is guarded. This is scaffolding *around* the app: if the plugin
/// is missing (test host) or the intent is malformed, the app must still
/// start normally.
@lazySingleton
class SharedRoutineReceiver {
  SharedRoutineReceiver(this._fileIo);

  final RoutineFileIo _fileIo;

  final StreamController<PickedRoutineFile> _incoming =
      StreamController<PickedRoutineFile>.broadcast();

  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _started = false;

  /// Routine files handed to the app by another app.
  Stream<PickedRoutineFile> get incoming => _incoming.stream;

  /// Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        _handle,
        onError: (Object error) =>
            debugPrint('SharedRoutineReceiver: stream failed: $error'),
      );
      // A share that launched the app is not replayed on the stream.
      await _handle(await ReceiveSharingIntent.instance.getInitialMedia());
    } catch (error, stackTrace) {
      debugPrint('SharedRoutineReceiver.start failed: $error\n$stackTrace');
    }
  }

  Future<void> _handle(List<SharedMediaFile> media) async {
    if (media.isEmpty) return;

    try {
      for (final item in media) {
        if (item.type != SharedMediaType.file) continue;
        final file = await _fileIo.readFile(File(item.path));
        if (file == null) continue;
        _incoming.add(file);
        // One routine per share: the import screen handles a single file, and
        // queueing several previews would stack sheets on top of each other.
        break;
      }
    } catch (error, stackTrace) {
      debugPrint('SharedRoutineReceiver: read failed: $error\n$stackTrace');
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
