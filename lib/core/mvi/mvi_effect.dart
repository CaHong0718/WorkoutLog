import 'package:equatable/equatable.dart';

/// A one-shot side effect: navigation, snack bar, haptic feedback.
///
/// Never modelled as state — replaying state must never replay an effect.
abstract class MviEffect extends Equatable {
  const MviEffect();

  @override
  List<Object?> get props => const [];
}
