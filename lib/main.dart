import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/notification/rest_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Channel and timezone data ready before the first rest ends.
  await getIt<RestNotifier>().init();
  runApp(const HealthApp());
}
