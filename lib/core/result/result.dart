import '../error/failure.dart';

/// Return type of every repository and use case.
///
/// Callers pattern-match instead of catching exceptions:
/// ```dart
/// switch (await getActiveRoutine()) {
///   case Ok(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) => switch (this) {
    Ok<T>(:final value) => onOk(value),
    Err<T>(:final failure) => onErr(failure),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  String toString() => 'Err($failure)';
}

/// Runs [body] and converts any thrown object into an [Err].
///
/// Used by repository implementations so that no exception escapes the data
/// layer. [onError] lets a caller classify the exception more precisely.
Future<Result<T>> runCatching<T>(
  Future<T> Function() body, {
  Failure Function(Object error)? onError,
}) async {
  try {
    return Ok(await body());
  } catch (error, stackTrace) {
    return Err(
      onError?.call(error) ??
          DatabaseFailure('데이터를 처리하지 못했습니다.', cause: '$error\n$stackTrace'),
    );
  }
}
