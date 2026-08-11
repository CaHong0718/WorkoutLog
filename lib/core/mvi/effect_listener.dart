import 'dart:async';

import 'package:flutter/widgets.dart';

/// Subscribes to a bloc's effect stream and invokes [onEffect] for each item.
///
/// ```dart
/// EffectListener<HomeEffect>(
///   stream: context.read<HomeBloc>().effects,
///   onEffect: (context, effect) => switch (effect) { ... },
///   child: ...,
/// )
/// ```
class EffectListener<E> extends StatefulWidget {
  const EffectListener({
    required this.stream,
    required this.onEffect,
    required this.child,
    super.key,
  });

  final Stream<E> stream;
  final void Function(BuildContext context, E effect) onEffect;
  final Widget child;

  @override
  State<EffectListener<E>> createState() => _EffectListenerState<E>();
}

class _EffectListenerState<E> extends State<EffectListener<E>> {
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant EffectListener<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen((effect) {
      if (mounted) {
        widget.onEffect(context, effect);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
