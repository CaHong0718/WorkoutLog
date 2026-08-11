import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';

/// Pill switch between the history views.
///
/// A plain `TabBar` is not used because it would need a global theme entry to
/// match the document's surfaces; this keeps the styling local to the screen.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // 4 + 36 + 4 keeps every segment on a 44pt touch target.
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: _Segment(
                label: labels[index],
                isSelected: index == selectedIndex,
                onTap: () => onChanged(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? p.surface : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSelected ? p.line : Colors.transparent),
        ),
        child: Text(
          label,
          style: context.type.label.copyWith(
            color: isSelected ? p.ink : p.ink3,
          ),
        ),
      ),
    );
  }
}
