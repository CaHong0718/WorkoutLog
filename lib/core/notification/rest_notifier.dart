import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Fires a local notification the moment a rest period ends.
///
/// The athlete trains with the screen off, so an in-app countdown is not
/// enough: the alert has to come from the system. The notification is
/// *scheduled* at the exact end time rather than posted by a Dart timer, so it
/// survives the app being backgrounded, the screen turning off, and Doze.
@lazySingleton
class RestNotifier {
  static const int _restNotificationId = 1001;
  static const String _channelId = 'rest_timer';
  static const String _channelName = '휴식 타이머';
  static const String _channelDescription = '휴식이 끝나면 알려줍니다.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  /// True once the system let us post notifications.
  bool get canNotify => _permissionGranted;

  /// Safe to call more than once. Never throws — losing the notification must
  /// not take the workout screen down with it.
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // iOS would otherwise put the permission prompt on the very first
          // frame. Asking is [ensurePermissions]' job, at the moment the user
          // starts a workout and the request explains itself.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      await _android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('RestNotifier.init failed: $error\n$stackTrace');
    }
  }

  /// Asks for the POST_NOTIFICATIONS permission (Android 13+) and, separately,
  /// for exact alarms — on iOS, for alert and sound. Call it when the user
  /// starts a workout — that is when the request makes sense to them.
  Future<void> ensurePermissions() async {
    await init();
    try {
      if (_android case final android?) {
        _permissionGranted =
            await android.requestNotificationsPermission() ?? false;
        // Exact alarms may be denied; scheduling falls back to inexact below.
        await android.requestExactAlarmsPermission();
      } else if (_ios case final ios?) {
        // No badge: the app counts sets, not unread items.
        _permissionGranted =
            await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
    } catch (error) {
      debugPrint('RestNotifier.ensurePermissions failed: $error');
    }
  }

  /// Schedules the "rest is over" alert for [endsAt], replacing any pending one.
  ///
  /// [nextLabel] names what comes next so the notification is useful from the
  /// lock screen without opening the app.
  Future<void> scheduleRestEnd({
    required DateTime endsAt,
    required String nextLabel,
  }) async {
    await init();
    if (!_initialized) return;

    await cancel();
    if (!endsAt.isAfter(DateTime.now())) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        enableVibration: true,
        // Wakes the screen; the phone is usually face-down on the bench.
        fullScreenIntent: false,
        ongoing: false,
        autoCancel: true,
      ),
      // `timeSensitive` would cut through Focus, but it needs the matching
      // entitlement on the provisioning profile; `active` works on a plain
      // build. See docs/05-IOS.md.
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBanner: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    // TZDateTime.from preserves the instant, so UTC is a correct reference even
    // though the device is not on UTC — the alarm still fires at [endsAt].
    final scheduled = tz.TZDateTime.from(endsAt, tz.UTC);

    for (final mode in const [
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ]) {
      try {
        await _plugin.zonedSchedule(
          id: _restNotificationId,
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: mode,
          title: '휴식 완료',
          body: nextLabel,
        );
        return;
      } catch (error) {
        // Exact alarms can be refused by the system; retry inexact once.
        debugPrint('RestNotifier.scheduleRestEnd($mode) failed: $error');
      }
    }
  }

  /// Drops a pending alert — the rest was skipped, extended or the session ended.
  Future<void> cancel() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: _restNotificationId);
    } catch (error) {
      debugPrint('RestNotifier.cancel failed: $error');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
}
