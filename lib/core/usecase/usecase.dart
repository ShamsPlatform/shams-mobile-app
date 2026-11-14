import 'package:shams_mobile_app/core/result/result.dart';

/// Base contract for asynchronous domain use cases returning a [Result].
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base contract for stream-based domain use cases.
abstract interface class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

/// Marker parameter class for use cases that require no arguments.
class NoParams {
  const NoParams();
}
