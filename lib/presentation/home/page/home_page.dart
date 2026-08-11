import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../common/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScaffold(title: AppStrings.todayRoutine, step: 'STEP 4');
}
