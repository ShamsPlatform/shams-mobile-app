import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shams_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late _MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  const userA = AuthUser(id: 'user-a', email: 'a@example.com');
  const userARefreshed = AuthUser(
    id: 'user-a',
    email: 'a@example.com',
    displayName: 'Updated',
  );
  const userB = AuthUser(id: 'user-b', email: 'b@example.com');

  setUp(() {
    remote = _MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote);
  });

  test('currentUser forwards value from remote data source', () {
    when(() => remote.currentUser).thenReturn(userA);
    expect(repository.currentUser, userA);
  });

  test('authStateChanges deduplicates emissions by user id', () {
    when(() => remote.authStateChanges()).thenAnswer(
      (_) => Stream<AuthUser?>.fromIterable([
        null,
        null,
        userA,
        userARefreshed,
        userB,
        null,
      ]),
    );

    expect(
      repository.authStateChanges(),
      emitsInOrder([null, userA, userB, null]),
    );
  });

  test('signInWithEmail returns Ok when remote succeeds', () async {
    when(
      () => remote.signInWithEmail(
        email: 'a@example.com',
        password: 'secret',
      ),
    ).thenAnswer((_) async => userA);

    final result = await repository.signInWithEmail(
      email: 'a@example.com',
      password: 'secret',
    );

    expect(result, const Ok(userA));
  });

  test('signInWithEmail maps AppAuthException to AuthFailure', () async {
    when(
      () => remote.signInWithEmail(
        email: 'a@example.com',
        password: 'wrong',
      ),
    ).thenThrow(const AppAuthException('البريد الإلكتروني أو كلمة المرور غير صحيحة'));

    final result = await repository.signInWithEmail(
      email: 'a@example.com',
      password: 'wrong',
    );

    expect(
      result,
      const Err<AuthUser>(
        AuthFailure('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
      ),
    );
  });

  test('signInWithGoogle maps SocketException to NetworkFailure', () async {
    when(() => remote.signInWithGoogle())
        .thenThrow(const SocketException('offline'));

    final result = await repository.signInWithGoogle();

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<NetworkFailure>());
  });

  test('signUp returns Ok on success and maps ServerException on failure',
      () async {
    when(
      () => remote.signUp(
        email: 'a@example.com',
        password: 'secret',
        fullName: 'Ali',
      ),
    ).thenAnswer((_) async => userA);

    final ok = await repository.signUp(
      email: 'a@example.com',
      password: 'secret',
      fullName: 'Ali',
    );
    expect(ok, const Ok(userA));

    when(
      () => remote.signUp(
        email: 'b@example.com',
        password: 'secret',
        fullName: 'B',
      ),
    ).thenThrow(const ServerException('server boom'));

    final err = await repository.signUp(
      email: 'b@example.com',
      password: 'secret',
      fullName: 'B',
    );
    expect(err, const Err<AuthUser>(ServerFailure('server boom')));
  });

  test('signOut returns Ok when remote completes', () async {
    when(() => remote.signOut()).thenAnswer((_) async {});

    final result = await repository.signOut();

    expect(result, isA<Ok<void>>());
    verify(() => remote.signOut()).called(1);
  });
}
