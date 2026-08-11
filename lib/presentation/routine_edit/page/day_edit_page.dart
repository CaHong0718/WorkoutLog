import 'package:flutter/material.dart';

import '../../common/common_widgets.dart';

class DayEditPage extends StatelessWidget {
  const DayEditPage({required this.dayId, super.key});

  final int dayId;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScaffold(title: 'DAY 편집', step: 'STEP 6');
}
