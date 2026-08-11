import 'package:flutter/widgets.dart';

/// Carries a "this branch is on screen again" signal down to the page inside a
/// bottom-navigation branch.
///
/// The shell keeps every branch alive, so a page is built once and then never
/// again — whatever it read on that first build is what it keeps showing. A
/// session finished from the home tab has to reach the calendar somehow, and
/// this is the wire it travels on. Installed by `BranchPager`, read by
/// [OnBranchReveal].
class BranchVisibility extends InheritedWidget {
  const BranchVisibility({
    required this.reveals,
    required super.child,
    super.key,
  });

  /// Notifies once per reveal. Deliberately value-less: two consecutive
  /// reveals of the same branch must both come through, so there is nothing
  /// worth comparing.
  final Listenable reveals;

  static Listenable? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BranchVisibility>()?.reveals;

  @override
  bool updateShouldNotify(BranchVisibility oldWidget) =>
      reveals != oldWidget.reveals;
}

/// Runs [onReveal] every time the branch hosting it becomes the visible tab.
///
/// Never on the branch's first visit: the page is built at that moment and its
/// own initial load is as fresh as a reveal would be. Outside a
/// [BranchVisibility] this is a plain pass-through, so a page can be both a tab
/// and something pushed on the root navigator.
class OnBranchReveal extends StatefulWidget {
  const OnBranchReveal({
    required this.onReveal,
    required this.child,
    super.key,
  });

  final VoidCallback onReveal;
  final Widget child;

  @override
  State<OnBranchReveal> createState() => _OnBranchRevealState();
}

class _OnBranchRevealState extends State<OnBranchReveal> {
  Listenable? _reveals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reveals = BranchVisibility.maybeOf(context);
    if (reveals == _reveals) return;
    _reveals?.removeListener(_handleReveal);
    _reveals = reveals;
    _reveals?.addListener(_handleReveal);
  }

  @override
  void dispose() {
    _reveals?.removeListener(_handleReveal);
    super.dispose();
  }

  void _handleReveal() => widget.onReveal();

  @override
  Widget build(BuildContext context) => widget.child;
}
