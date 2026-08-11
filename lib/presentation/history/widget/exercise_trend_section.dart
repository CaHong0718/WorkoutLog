import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/date_time_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/exercise_progress_point.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';
import '../bloc/stats_state.dart';
import 'trend_exercise_picker.dart';

/// Top weight and Epley 1RM for one exercise over time.
///
/// Two series on purpose: the top weight is what was lifted, the estimate is
/// what it is worth once the rep range changes between sessions.
class ExerciseTrendSection extends StatelessWidget {
  const ExerciseTrendSection({
    required this.state,
    required this.onSelect,
    super.key,
  });

  final StatsState state;
  final void Function(int exerciseId) onSelect;

  @override
  Widget build(BuildContext context) {
    if (state.trendExercises.isEmpty) {
      return SectionCard(
        child: Text(AppStrings.noTrendExercise, style: context.type.caption),
      );
    }

    final exercise = state.selectedExercise;
    final color = exercise?.bodyPart.color(context) ?? context.palette.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          accent: color,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise?.name ?? AppStrings.selectTrendExercise,
                      style: context.type.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (exercise != null) ...[
                      const SizedBox(height: 6),
                      BodyPartChip(exercise.bodyPart, dense: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _pick(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(AppStrings.changeExercise),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: state.isTrendLoading
              ? const SizedBox(height: 200, child: LoadingView())
              : state.hasTrend
              ? _TrendBody(points: state.progress, color: color)
              : _NotEnoughData(points: state.progress),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await TrendExercisePicker.show(
      context,
      exercises: state.trendExercises,
      selectedId: state.selectedExerciseId,
    );
    if (picked != null) onSelect(picked);
  }
}

class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData({required this.points});

  final List<ExerciseProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final single = points.length == 1 ? points.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.trendNeedsMoreData, style: context.type.caption),
        if (single != null) ...[
          const SizedBox(height: 10),
          Text(
            '${single.date.formatShort}  '
            '${_trim(single.topWeight)}kg × ${single.reps}',
            style: context.type.numeric,
          ),
        ],
      ],
    );
  }
}

class _TrendBody extends StatelessWidget {
  const _TrendBody({required this.points, required this.color});

  final List<ExerciseProgressPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final latest = points.last;
    final first = points.first;
    final delta = latest.topWeight - first.topWeight;

    final Color deltaColor;
    if (delta > 0) {
      deltaColor = p.accent;
    } else if (delta < 0) {
      deltaColor = p.warn;
    } else {
      deltaColor = p.ink3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: color, label: AppStrings.topWeight),
            const SizedBox(width: 14),
            _LegendDot(
              color: p.ink3,
              label: AppStrings.estimated1RM,
              dashed: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(height: 200, child: _chart(context)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                '${AppStrings.latestRecord} ${latest.date.formatShort}  '
                '${_trim(latest.topWeight)}kg × ${latest.reps}',
                style: context.type.caption.copyWith(color: p.ink2),
              ),
            ),
            Text(
              delta == 0 ? '—' : '${delta > 0 ? '+' : ''}${_trim(delta)}kg',
              style: context.type.numeric.copyWith(
                fontSize: 13,
                color: deltaColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chart(BuildContext context) {
    final p = context.palette;
    final values = <double>[
      for (final point in points) point.topWeight,
      for (final point in points) point.estimated1RM,
    ];
    var lowest = values.first;
    var highest = values.first;
    for (final value in values) {
      lowest = math.min(lowest, value);
      highest = math.max(highest, value);
    }

    final span = highest - lowest;
    final pad = span < 5 ? 2.5 : span * 0.18;
    final minY = math.max(0, lowest - pad).toDouble();
    final maxY = highest + pad;
    final gridStep = math.max((maxY - minY) / 4, 0.5);
    final labelStep = math.max(1, (points.length / 4).ceil()).toDouble();

    final axisStyle = context.type.caption.copyWith(fontSize: 10.5);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: gridStep,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: p.lineSoft, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: gridStep,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 6,
                child: Text('${value.round()}', style: axisStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: labelStep,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(points[index].date.formatShort, style: axisStyle),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => p.ink,
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  '${_trim(spot.y)}kg',
                  TextStyle(
                    color: p.surface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].topWeight),
            ],
            color: color,
            barWidth: 2.4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(radius: 3, color: color),
            ),
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].estimated1RM),
            ],
            color: p.ink3,
            barWidth: 1.6,
            dashArray: const [5, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: dashed ? 2 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.type.label),
      ],
    );
  }
}

/// `62.5` / `60` — drops the decimal when the weight is whole.
String _trim(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
