import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';

/// `2,350` — tonnage rounded to whole kilos, grouped in thousands.
///
/// Written by hand rather than through `intl` so no locale has to be
/// initialised before the first frame.
String formatKg(double value) {
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  final grouped = buffer.toString();
  return value < 0 ? '-$grouped' : grouped;
}

/// Micro label over a large tabular number — the document's stat block.
class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    this.unit,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final String? unit;

  /// Overrides the number color, used to tint a body-part specific metric.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: context.type.label),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.metric.copyWith(
                  fontSize: 24,
                  color: color ?? p.ink,
                ),
              ),
            ),
            if (unit != null)
              Text(
                ' ${unit!}',
                style: context.type.caption.copyWith(color: p.ink3),
              ),
          ],
        ),
      ],
    );
  }
}

/// Thin vertical rule between two [MetricTile]s.
class MetricDivider extends StatelessWidget {
  const MetricDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: context.palette.lineSoft);
}
