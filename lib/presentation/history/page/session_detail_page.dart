import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../common/common_widgets.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScaffold(title: AppStrings.sessionDetail, step: 'STEP 7');
}
