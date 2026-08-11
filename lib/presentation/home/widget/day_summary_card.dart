import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../../domain/entity/routine_day.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../../common/volume_rail.dart';

/// The hero card: which day is on today and what it costs.
class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({required this.day, super.key});

  final RoutineDay day;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = day.primaryBodyPart.color(context);
    final volume = day.volumeByBodyPart;

    return SectionCard(
      accent: accent,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayTag(code: day.code, color: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.title, style: context.type.sectionTitle),
                    if (day.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          day.subtitle!,
                          style: context.type.caption.copyWith(color: accent),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric(value: '${day.totalSets}', unit: 'Sets'),
              _MetricDivider(color: p.lineSoft),
              _Metric(value: '${day.estimatedMinutes}', unit: 'Min'),
              _MetricDivider(color: p.lineSoft),
              _Metric(
                value: '${volume[day.primaryBodyPart] ?? 0}',
                unit: '${day.primaryBodyPart.label} Sets',
              ),
            ],
          ),
          if (day.description != null) ...[
            const SizedBox(height: 14),
            Text(day.description!, style: context.type.body),
          ],
          const SizedBox(height: 16),
          VolumeRail(segments: _segments(context, volume)),
        ],
      ),
    );
  }

  List<RailSegment> _segments(BuildContext context, Map<BodyPart, int> volume) {
    final entries = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in entries)
        RailSegment(
          flex: entry.value,
          color: entry.key.color(context),
          label: '${entry.key.label} ${entry.value}',
        ),
    ];
  }
}

class _DayTag extends StatelessWidget {
  const _DayTag({required this.code, required this.color});

  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.unit});

  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.type.metric.copyWith(fontSize: 28)),
          const SizedBox(height: 3),
          Text(unit, style: context.type.label),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: color);
}
