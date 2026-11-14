import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/get_current_auth_user_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  group('SignInWithEmailUseCase', () {
    late SignInWithEmailUseCase useCase;
    const testUser = AuthUser(id: 'u-1', email: 'user@example.com');

    setUp(() {
      useCase = SignInWithEmailUseCase(repo);
    });

    test('returns AuthFailure when email is empty after trim', () async {
      final result = await useCase(
        const SignInWithEmailParams(email: '   ', password: 'secret'),
      );

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        const AuthFailure('يرجى التحقق من البريد الإلكتروني'),
      );
      verifyNever(
        () => repo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('returns AuthFailure when password is empty', () async {
      final result = await useCase(
        const SignInWithEmailParams(email: 'user@example.com', password: ''),
      );

      expect(result, isA<Err<AuthUser>>());
      expect(
        (result as Err<AuthUser>).failure,
        const AuthFailure('كلمة المرور غير صحيحة'),
      );
      verifyNever(
        () => repo.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('trims email and forwards credentials to repository', () async {
      when(
        () => repo.signInWithEmail(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => const Ok(testUser));

      final result = await useCase(
        const SignInWithEmailParams(
          email: '  user@example.com  ',
          password: 'password123',
        ),
      );

      expect(result, isA<Ok<AuthUser>>());
      expect((result as Ok<AuthUser>).data, testUser);
      verify(
        () => repo.signInWithEmail(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('SignInWithGoogleUseCase', () {
    test('delegates to repository', () async {
      final useCase = SignInWithGoogleUseCase(repo);
      when(() => repo.signInWithGoogle())
          .thenAnswer((_) async => const Ok(null));

      final result = await useCase(const NoParams());

      expect(result, isA<Ok<void>>());
      verify(() => repo.signInWithGoogle()).called(1);
    });
  });

  group('SignOutUseCase', () {
    test('delegates to repository', () async {
      final useCase = SignOutUseCase(repo);
      when(() => repo.signOut()).thenAnswer((_) async => const Ok(null));

      final result = await useCase(const NoParams());

      expect(result, isA<Ok<void>>());
      verify(() => repo.signOut()).called(1);
    });
  });

  group('WatchAuthStateUseCase', () {
    test('forwards stream from repository', () {
      final useCase = WatchAuthStateUseCase(repo);
      const user = AuthUser(id: 'u-1');
      final stream = Stream<AuthUser?>.fromIterable([null, user]);
      when(() => repo.authStateChanges()).thenAnswer((_) => stream);

      expect(useCase(const NoParams()), emitsInOrder([null, user]));
      verify(() => repo.authStateChanges()).called(1);
    });
  });

  group('GetCurrentAuthUserUseCase', () {
    test('returns current user synchronously from repository', () {
      final useCase = GetCurrentAuthUserUseCase(repo);
      const user = AuthUser(id: 'u-2', email: 'a@b.c');
      when(() => repo.currentUser).thenReturn(user);

      expect(useCase(), user);
      verify(() => repo.currentUser).called(1);
    });
  });
}
