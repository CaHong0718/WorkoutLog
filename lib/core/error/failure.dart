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

/// Anything that was not anticipated.
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
