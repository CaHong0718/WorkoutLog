import 'package:flutter/material.dart';

import '../../../core/extensions/date_time_x.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../common/body_part_ui.dart';
import '../../common/common_widgets.dart';

/// Month grid with a colored dot on every day that has a completed session.
///
/// The week starts on Monday, matching `DateRange.week` and the weekly volume
/// aggregation, so a marked row and a volume bar always cover the same days.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.month,
    required this.markedDates,
    required this.dayBodyParts,
    required this.selectedDate,
    required this.onChangeMonth,
    required this.onSelectDate,
    this.isLoading = false,
    super.key,
  });

  final DateTime month;
  final Set<DateTime> markedDates;
  final Map<DateTime, BodyPart> dayBodyParts;
  final DateTime? selectedDate;
  final bool isLoading;
  final void Function(int delta) onChangeMonth;
  final void Function(DateTime date) onSelectDate;

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = DateTime.now().dateOnly;
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstDay.weekday - DateTime.monday;
    final rowCount = ((leading + daysInMonth) / 7).ceil();
    final canGoForward = month.isBefore(today.startOfMonth);

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                onPressed: () => onChangeMonth(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${month.year}년 ${month.month}월',
                    style: context.type.sectionTitle,
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right,
                onPressed: canGoForward ? () => onChangeMonth(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final label in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: context.type.label.copyWith(
                        color: label == '일' ? p.danger : p.ink3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Opacity(
            opacity: isLoading ? 0.4 : 1,
            child: Column(
              children: [
                for (var row = 0; row < rowCount; row++)
                  Row(
                    children: [
                      for (var column = 0; column < 7; column++)
                        Expanded(
                          child: _buildCell(
                            context,
                            dayNumber: row * 7 + column - leading + 1,
                            daysInMonth: daysInMonth,
                            today: today,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required int dayNumber,
    required int daysInMonth,
    required DateTime today,
  }) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 46);
    }

    final p = context.palette;
    final date = DateTime(month.year, month.month, dayNumber);
    final isSelected = selectedDate != null && selectedDate!.isSameDay(date);
    final isToday = today.isSameDay(date);
    final isMarked = markedDates.contains(date);
    final markerColor = dayBodyParts[date]?.color(context) ?? p.accentFill;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: () => onSelectDate(date),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? p.accentWash : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? p.accent
                  : isToday
                  ? p.line
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNumber',
                style: context.type.numeric.copyWith(
                  fontSize: 13.5,
                  fontWeight: isMarked ? FontWeight.w600 : FontWeight.w400,
                  color: isMarked ? p.ink : p.ink3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMarked ? markerColor : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      color: p.ink2,
      disabledColor: p.line,
      visualDensity: VisualDensity.compact,
    );
  }
}
