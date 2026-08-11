import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../common/common_widgets.dart';
import '../../common/volume_rail.dart';

/// This week's completed sets against the routine's own weekly target.
class WeeklyVolumePanel extends StatelessWidget {
  const WeeklyVolumePanel({
    required this.done,
    required this.target,
    super.key,
  });

  final Map<BodyPart, int> done;
  final Map<BodyPart, int> target;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final doneTotal = done.values.fold(0, (sum, v) => sum + v);
    final targetTotal = target.values.fold(0, (sum, v) => sum + v);

    final parts = target.keys.toList()
      ..sort((a, b) => (target[b] ?? 0).compareTo(target[a] ?? 0));

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이번 주 볼륨', style: context.type.cardTitle),
                    const SizedBox(height: 2),
                    Text('월요일 시작 · 완료된 세트만 집계', style: context.type.caption),
                  ],
                ),
              ),
              Text('$doneTotal', style: context.type.metric),
              Text(
                ' / $targetTotal',
                style: context.type.caption.copyWith(
                  fontFeatures: AppTypography.tabular,
                  color: p.ink3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (parts.isEmpty)
            Text('루틴 볼륨 정보가 없습니다', style: context.type.caption)
          else
            for (final part in parts)
              VolumeProgressRow(
                bodyPart: part,
                done: done[part] ?? 0,
                target: target[part] ?? 0,
              ),
        ],
      ),
    );
  }
}
