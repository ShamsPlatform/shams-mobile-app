import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';

void main() {
  group('guard', () {
    test('returns Ok when body completes normally', () async {
      final result = await guard(() async => 'hello');

      expect(result, const Ok('hello'));
    });

    test('maps AppAuthException to AuthFailure', () async {
      final result = await guard<void>(
        () async => throw const AppAuthException('auth failed'),
      );

      expect(result, const Err<void>(AuthFailure('auth failed')));
    });

    test('maps NotFoundException to NotFoundFailure', () async {
      final result = await guard<void>(
        () async => throw const NotFoundException('missing'),
      );

      expect(result, const Err<void>(NotFoundFailure('missing')));
    });

    test('maps ServerException to ServerFailure', () async {
      final result = await guard<void>(
        () async => throw const ServerException('db error'),
      );

      expect(result, const Err<void>(ServerFailure('db error')));
    });

    test('maps CacheException to CacheFailure', () async {
      final result = await guard<void>(
        () async => throw const CacheException('cache error'),
      );

      expect(result, const Err<void>(CacheFailure('cache error')));
    });

    test('maps SocketException to NetworkFailure', () async {
      final result = await guard<void>(
        () async => throw const SocketException('offline'),
      );

      expect(result, const Err<void>(NetworkFailure()));
    });

    test('maps unexpected errors to UnknownFailure', () async {
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {};
      addTearDown(() => debugPrint = originalDebugPrint);

      final result = await guard<void>(
        () async => throw StateError('unexpected'),
      );

      expect(result, const Err<void>(UnknownFailure()));
    });
  });
}
