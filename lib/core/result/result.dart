import 'package:shams_mobile_app/core/error/failures.dart';

/// Represents either a successful value [Ok] or a [Failure] wrapped in [Err].
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onErr, R Function(T data) onOk) =>
      switch (this) {
        Ok<T>(:final data) => onOk(data),
        Err<T>(:final failure) => onErr(failure),
      };
}

final class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ok<T> && other.data == data;

  @override
  int get hashCode => Object.hash(Ok, data);

  @override
  String toString() => 'Ok($data)';
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}
