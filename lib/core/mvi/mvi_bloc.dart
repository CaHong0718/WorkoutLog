import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'mvi_effect.dart';
import 'mvi_intent.dart';
import 'mvi_state.dart';

/// Base bloc for the MVI contract: `Intent → Bloc → State (+ Effect)`.
///
/// [State] is emitted through the normal bloc stream; [Effect] travels on a
/// separate broadcast stream so it fires exactly once per emission.
abstract class MviBloc<I extends MviIntent, S extends MviState, E extends MviEffect>
    extends Bloc<I, S> {
  MviBloc(super.initialState);

  final StreamController<E> _effects = StreamController<E>.broadcast();

  /// Subscribe with `EffectListener`.
  Stream<E> get effects => _effects.stream;

  /// Emits a one-shot side effect. Safe to call after [close].
  void emitEffect(E effect) {
    if (!_effects.isClosed) {
      _effects.add(effect);
    }
  }

  @override
  Future<void> close() async {
    await _effects.close();
    return super.close();
  }
}

/// Processes events one at a time, in arrival order.
///
/// Bloc's default transformer is concurrent: two taps on the same button start
/// two handlers that both read the pre-tap state. Any handler that writes to
/// the database must use this instead.
EventTransformer<E> sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
