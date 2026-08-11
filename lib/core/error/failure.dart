import 'package:equatable/equatable.dart';

/// Base type for every recoverable error crossing a layer boundary.
///
/// Data layer catches infrastructure exceptions and converts them into a
/// [Failure]; domain and presentation never see raw exceptions.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// User-facing Korean message.
  final String message;

  /// Original exception, kept for logging only.
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];

  @override
  String toString() => '$runtimeType($message)';
}

/// Any error originating from the local database.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.cause});
}

/// The requested row does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause});
}

/// Input did not satisfy a domain rule.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

/// A routine exchange file could not be read.
///
/// Separate from [ValidationFailure] because the import screen lists every
/// problem at once — collapsing them into a single sentence would hide all but
/// the first typo in a hand-written file.
final class RoutineFormatFailure extends Failure {
  const RoutineFormatFailure(
    super.message, {
    this.errors = const [],
    super.cause,
  });

  /// One line per problem, each prefixed with its path inside the document:
  /// `routine.days[1].blocks[0].items[2].repMax: ...`
  final List<String> errors;

  @override
  List<Object?> get props => [message, errors, cause];
}

/// Anything that was not anticipated.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
