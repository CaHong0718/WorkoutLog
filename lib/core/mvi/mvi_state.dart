import 'package:equatable/equatable.dart';

/// The complete, immutable state of one screen.
///
/// Loading and error are fields of a single state object rather than separate
/// subclasses, so partial updates never discard already-loaded data.
abstract class MviState extends Equatable {
  const MviState();
}
