import 'package:flutter/material.dart';

/// Drops text-field focus when the user taps anywhere that does not handle the
/// tap itself, so the keyboard closes on an outside tap.
///
/// Uses [HitTestBehavior.translucent] so buttons, list rows and scroll
/// gestures underneath keep working — this only claims taps nothing else
/// consumed.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      onTap: () {
        final focus = FocusManager.instance.primaryFocus;
        if (focus != null && focus.hasFocus) focus.unfocus();
      },
      child: child,
    );
  }
}
