import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entity/enums.dart';
import '../../common/body_part_ui.dart';

/// Bottom-sheet frame shared by every editor sheet: title, scrollable body,
/// cancel / save footer, keyboard-aware padding.
class EditSheet extends StatelessWidget {
  const EditSheet({
    required this.title,
    required this.children,
    required this.onSave,
    this.subtitle,
    this.saveLabel = AppStrings.save,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Null disables the save button (invalid input).
  final VoidCallback? onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.86),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.type.sectionTitle),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(subtitle!, style: context.type.caption),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  children: children,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: onSave,
                        child: Text(saveLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `라운드 수   [-]  3  [+]` — every numeric field in the editors uses this
/// instead of a text field, so there is nothing to validate.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 0,
    this.max = 999,
    this.suffix = '',
    this.enabled = true,
    super.key,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int min;
  final int max;
  final String suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canDecrease = enabled && value - step >= min;
    final canIncrease = enabled && value + step <= max;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.type.body)),
          IconButton(
            onPressed: canDecrease ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value$suffix',
              textAlign: TextAlign.center,
              style: context.type.numeric.copyWith(
                color: enabled ? null : context.palette.ink3,
              ),
            ),
          ),
          IconButton(
            onPressed: canIncrease ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Body-part chips in their identity colors. [includeAll] adds a null option
/// used by the library filter.
class BodyPartSelector extends StatelessWidget {
  const BodyPartSelector({
    required this.value,
    required this.onChanged,
    this.includeAll = false,
    super.key,
  });

  final BodyPart? value;
  final ValueChanged<BodyPart?> onChanged;
  final bool includeAll;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Wrap(
      spacing: 8,
      runSpacing: 2,
      children: [
        if (includeAll)
          _Chip(
            label: AppStrings.allBodyParts,
            color: p.ink2,
            selected: value == null,
            onSelected: () => onChanged(null),
          ),
        for (final part in BodyPart.values)
          _Chip(
            label: part.label,
            color: part.color(context),
            selected: value == part,
            onSelected: () => onChanged(part),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: color.withValues(alpha: 0.16),
      side: BorderSide(
        color: selected ? color : context.palette.line,
        width: selected ? 1.4 : 1,
      ),
      labelStyle: context.type.caption.copyWith(
        color: selected ? color : context.palette.ink2,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Destructive confirmation shared by day / block / item / exercise deletion.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: context.type.sectionTitle),
      content: Text(message, style: context.type.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(AppStrings.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
