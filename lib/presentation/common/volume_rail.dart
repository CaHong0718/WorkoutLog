import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entity/enums.dart';
import 'body_part_ui.dart';

/// One segment of a proportional time/volume bar.
class RailSegment {
  const RailSegment({
    required this.flex,
    required this.color,
    required this.label,
  });

  final int flex;
  final Color color;
  final String label;
}

/// Horizontal proportional bar, the document's `rail` element.
class VolumeRail extends StatelessWidget {
  const VolumeRail({required this.segments, this.height = 26, super.key});

  final List<RailSegment> segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (final segment in segments)
              Expanded(
                flex: segment.flex,
                child: Container(
                  color: segment.color,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      segment.label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `어깨 ████████░░ 12 / 19` — a labelled progress row per body part.
class VolumeProgressRow extends StatelessWidget {
  const VolumeProgressRow({
    required this.bodyPart,
    required this.done,
    required this.target,
    super.key,
  });

  final BodyPart bodyPart;
  final int done;
  final int target;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = bodyPart.color(context);
    final ratio = target == 0 ? 0.0 : (done / target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              bodyPart.label,
              style: context.type.caption.copyWith(
                color: p.ink2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(height: 8, color: p.surface3),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(height: 8, color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$done',
            style: context.type.numeric.copyWith(fontSize: 13.5),
          ),
          Text(
            ' / $target',
            style: context.type.caption.copyWith(
              fontFeatures: AppTypography.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
