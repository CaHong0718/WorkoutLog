import 'package:flutter/material.dart';

import '../../common/common_widgets.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScaffold(title: '운동 중', step: 'STEP 5');
}
