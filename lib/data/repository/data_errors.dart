import '../../core/error/failure.dart';

/// Thrown inside a repository when a lookup returns no row, so `runCatching`
/// can turn it into a [NotFoundFailure] instead of a generic database error.
class NotFoundException implements Exception {
  const NotFoundException(this.message);

  final String message;

  @override
  String toString() => 'NotFoundException($message)';
}

/// Thrown when input violates a domain rule detected at the data layer
/// (for example deleting an exercise a routine still references).
class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException($message)';
}

/// Maps repository-internal exceptions onto [Failure]s.
Failure classifyFailure(Object error) => switch (error) {
  NotFoundException(:final message) => NotFoundFailure(message),
  ValidationException(:final message) => ValidationFailure(message),
  _ => DatabaseFailure('데이터를 처리하지 못했습니다.', cause: error),
};
