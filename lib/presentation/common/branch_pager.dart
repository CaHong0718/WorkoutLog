import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'branch_reveal.dart';

/// Holds the bottom navigation's branches in a [PageView] so they can be
/// swiped between, and tells each branch when it comes on screen.
///
/// Replaces go_router's default `IndexedStack` container. The branch children
/// keep themselves alive inside the viewport, so a swipe away and back does not
/// rebuild the page — which is why they get a [BranchVisibility] to reload
/// through instead.
class BranchPager extends StatefulWidget {
  const BranchPager({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// One branch navigator per bottom-navigation destination, in order.
  final List<Widget> children;

  @override
  State<BranchPager> createState() => _BranchPagerState();
}

class _BranchPagerState extends State<BranchPager> {
  static const _settleDuration = Duration(milliseconds: 240);

  late final PageController _controller;
  late final List<_Reveal> _reveals;

  /// The branch last seen on screen. Set eagerly in [initState]: a `late`
  /// initializer would first run inside [didUpdateWidget], reading the index
  /// the shell had *just moved to* and so never noticing the move.
  late int _index;

  /// True while the pager animates towards a tapped destination. That animation
  /// crosses every page in between and `onPageChanged` reports each one;
  /// switching branches on those would cut the animation short.
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _index = widget.navigationShell.currentIndex;
    _controller = PageController(initialPage: _index);
    _reveals = List<_Reveal>.generate(
      widget.children.length,
      (_) => _Reveal(),
      growable: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final reveal in _reveals) {
      reveal.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BranchPager oldWidget) {
    super.didUpdateWidget(oldWidget);

    // `currentIndex` lives on the shell widget, which go_router rebuilds on
    // every branch change — a swipe and a tab tap both land here.
    final index = widget.navigationShell.currentIndex;
    if (index == _index) return;
    _index = index;

    _reveals[index].fire();
    if (_controller.hasClients && _controller.page?.round() != index) {
      _settleTo(index);
    }
  }

  Future<void> _settleTo(int index) async {
    _settling = true;
    await _controller.animateToPage(
      index,
      duration: _settleDuration,
      curve: Curves.easeOutCubic,
    );
    _settling = false;
  }

  /// Fires the moment a drag passes the halfway mark rather than when it
  /// settles, so the branch has reloaded by the time the page lands.
  void _onPageChanged(int index) {
    if (_settling || index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: _onPageChanged,
      children: [
        for (final (index, child) in widget.children.indexed)
          BranchVisibility(reveals: _reveals[index], child: child),
      ],
    );
  }
}

/// A signal with no payload, so every reveal of the same branch gets through.
class _Reveal extends ChangeNotifier {
  void fire() => notifyListeners();
}
