import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

/// Weight increment of the stepper buttons — one 1.25 kg plate per side.
const double kWeightStep = 2.5;

/// A blank field and a typed `0` both mean the set carried no external load,
/// so both are read as 맨몸 rather than as `0kg`.
bool isBodyweightInput(String text) {
  final value = double.tryParse(text);
  return value == null || value == 0;
}

/// `62.5` → `62.5`, `60.0` → `60`.
String trimWeight(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// Number field flanked by −/+ steppers. Shared by the session card and the
/// set-log edit sheet so both read and behave identically.
class SetNumberRow extends StatelessWidget {
  const SetNumberRow({
    required this.label,
    required this.suffix,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    this.decimal = false,
    this.zeroSuffix,
    super.key,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool decimal;

  /// Replaces [suffix] while the field is blank or zero, so the weight row can
  /// say 맨몸 instead of kg for a set that carries no load.
  final String? zeroSuffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label, style: context.type.label)),
        _StepButton(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 8),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
                ),
              ],
              style: context.type.numeric.copyWith(fontSize: 19),
              decoration: InputDecoration(
                suffixText: zeroSuffix != null && isBodyweightInput(value.text)
                    ? zeroSuffix
                    : suffix,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StepButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface2,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: p.line),
          ),
          child: Icon(icon, size: 20, color: p.ink2),
        ),
      ),
    );
  }
}

/// Reps-in-reserve picker. Tapping the selected chip clears it.
class RirSelector extends StatelessWidget {
  const RirSelector({required this.value, required this.onChanged, super.key});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(AppStrings.rir, style: context.type.label),
        ),
        for (final option in const [0, 1, 2, 3])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _RirChip(
                label: '$option',
                selected: value == option,
                onTap: () => onChanged(value == option ? null : option),
              ),
            ),
          ),
      ],
    );
  }
}

class _RirChip extends StatelessWidget {
  const _RirChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.accentWash : p.surface2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? p.accentFill : p.line),
          ),
          child: Text(
            label,
            style: context.type.numeric.copyWith(
              fontSize: 14,
              color: selected ? p.accent : p.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
