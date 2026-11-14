import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';

void main() {
  group('Result', () {
    test('Ok.fold invokes onOk with the data', () {
      const Result<int> result = Ok(42);

      final output = result.fold(
        (failure) => 'err: ${failure.message}',
        (data) => 'ok: $data',
      );

      expect(output, 'ok: 42');
    });

    test('Err.fold invokes onErr with the failure', () {
      const Result<int> result = Err(ServerFailure('boom'));

      final output = result.fold(
        (failure) => 'err: ${failure.message}',
        (data) => 'ok: $data',
      );

      expect(output, 'err: boom');
    });

    test('supports value equality', () {
      expect(const Ok(1), const Ok(1));
      expect(const Ok(1), isNot(const Ok(2)));
      expect(
        const Err<int>(NetworkFailure()),
        const Err<int>(NetworkFailure()),
      );
      expect(
        const Err<int>(ServerFailure('a')),
        isNot(const Err<int>(ServerFailure('b'))),
      );
    });
  });
}
