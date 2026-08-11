import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_palette.dart';

/// A [ReorderableListView.proxyDecorator] that lifts an item in its own shape.
///
/// The framework default wraps the dragged item in `Material(elevation: 6)` —
/// canvas colour, square corners. A rounded card therefore leaves the list
/// inside a rectangle: the fill squares off the corners the card just drew, and
/// the box runs past the card into the gap that separates it from the next row.
/// This decorator draws only a rounded shadow behind the item, inset at the
/// bottom by [bottomGap] so it ends where the card does, and lets the item keep
/// painting its own surface and border.
///
/// Rows with no surface of their own pass [filled] so they stay legible while
/// floating over the list.
///
/// The shadow is the one `design/DESIGN.md` grants things that really are
/// floating (opacity .08 / blur 12 / offsetY 4). It fades in with the drag and
/// back out on release, so no card carries a shadow at rest.
ReorderItemProxyDecorator roundedDragProxy({
  double radius = AppRadius.card,
  double bottomGap = 0,
  bool filled = false,
}) {
  return (Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final lift = Curves.easeInOut.transform(animation.value);
        return Material(
          // The item brings its own surface; this only supplies the Material
          // ancestor that ink and text need once the proxy is in the overlay.
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: bottomGap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: filled ? context.palette.surface2 : null,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08 * lift),
                        blurRadius: 12 * lift,
                        offset: Offset(0, 4 * lift),
                      ),
                    ],
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: child,
    );
  };
}
