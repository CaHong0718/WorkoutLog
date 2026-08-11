import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entity/enums.dart';

/// Maps a [BodyPart] onto its identity color.
///
/// Lives in presentation, not core: `core` must not know about the domain,
/// and presentation → domain is the allowed direction.
extension BodyPartUi on BodyPart {
  Color color(BuildContext context) {
    final p = context.palette;
    return switch (this) {
      BodyPart.back => p.back,
      BodyPart.chest => p.chest,
      BodyPart.shoulder => p.shoulder,
      BodyPart.legs => p.legs,
      BodyPart.arms => p.arms,
      BodyPart.abs => p.abs,
    };
  }

  IconData get icon => switch (this) {
    BodyPart.back => Icons.swipe_down_alt_outlined,
    BodyPart.chest => Icons.fitness_center_outlined,
    BodyPart.shoulder => Icons.open_in_full_outlined,
    BodyPart.legs => Icons.airline_seat_legroom_extra_outlined,
    BodyPart.arms => Icons.sports_martial_arts_outlined,
    BodyPart.abs => Icons.grid_on_outlined,
  };
}

/// Small rounded tag showing a body part in its identity color.
class BodyPartChip extends StatelessWidget {
  const BodyPartChip(this.bodyPart, {this.trailing, this.dense = false, super.key});

  final BodyPart bodyPart;

  /// Optional suffix such as a set count.
  final String? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = bodyPart.color(context);
    final text = trailing == null ? bodyPart.label : '${bodyPart.label} $trailing';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 2 : 3.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: context.type.label.copyWith(
          color: color,
          fontSize: dense ? 10.5 : 11.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// 3px vertical identity bar placed at the leading edge of a row.
class BodyPartBar extends StatelessWidget {
  const BodyPartBar(this.bodyPart, {this.height = 16, super.key});

  final BodyPart bodyPart;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: height,
    decoration: BoxDecoration(
      color: bodyPart.color(context),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
