import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/get_current_auth_user_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockAuthRepository authRepo;
  late _MockProfileRepository profileRepo;
  late StreamController<AuthUser?> authStream;
  late AuthProvider provider;

  const testUser = AuthUser(
    id: 'u-1',
    email: 'ali@example.com',
    displayName: 'علي',
  );

  setUpAll(() {
    registerFallbackValue(
      const ProfileUpsert(
        id: 'id',
        name: 'name',
        username: 'username',
        location: 'صنعاء',
        email: 'a@b.c',
      ),
    );
  });

  setUp(() {
    authRepo = _MockAuthRepository();
    profileRepo = _MockProfileRepository();
    authStream = StreamController<AuthUser?>.broadcast();

    when(() => authRepo.currentUser).thenReturn(null);
    when(() => authRepo.authStateChanges()).thenAnswer((_) => authStream.stream);

    provider = AuthProvider(
      watchAuthState: WatchAuthStateUseCase(authRepo),
      getCurrentAuthUser: GetCurrentAuthUserUseCase(authRepo),
      signInWithEmail: SignInWithEmailUseCase(authRepo),
      signInWithGoogle: SignInWithGoogleUseCase(authRepo),
      completeSignUp: CompleteSignUpUseCase(authRepo, profileRepo),
      signOut: SignOutUseCase(authRepo),
    );
  });

  tearDown(() async {
    provider.dispose();
    await authStream.close();
  });

  test('starts unknown and reacts to auth stream emissions', () async {
    expect(provider.status, AuthStatus.unknown);

    provider.start();
    authStream.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(provider.status, AuthStatus.unauthenticated);
    expect(provider.currentUser, isNull);

    authStream.add(testUser);
    await Future<void>.delayed(Duration.zero);
    expect(provider.status, AuthStatus.authenticated);
    expect(provider.currentUser, testUser);
  });

  test('signInWithEmail updates status and clears/sets errorMessage', () async {
    when(
      () => authRepo.signInWithEmail(
        email: 'bad@example.com',
        password: 'wrong',
      ),
    ).thenAnswer((_) async => const Err(AuthFailure('بيانات خاطئة')));

    final failResult = await provider.signInWithEmail(
      email: 'bad@example.com',
      password: 'wrong',
    );
    expect(failResult, isFalse);
    expect(provider.actionStatus, ViewStatus.failure);
    expect(provider.errorMessage, 'بيانات خاطئة');

    when(
      () => authRepo.signInWithEmail(
        email: 'ali@example.com',
        password: 'secret',
      ),
    ).thenAnswer((_) async => const Ok(testUser));

    final okResult = await provider.signInWithEmail(
      email: 'ali@example.com',
      password: 'secret',
    );
    expect(okResult, isTrue);
    expect(provider.actionStatus, ViewStatus.success);
    expect(provider.errorMessage, isNull);
    expect(provider.status, AuthStatus.authenticated);
    expect(provider.currentUser, testUser);
  });

  test('completeSignUp buffers auth stream emissions until profile upsert completes',
      () async {
    provider.start();
    authStream.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(provider.status, AuthStatus.unauthenticated);

    final upsertCompleter = Completer<Result<void>>();

    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'secret',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async {
      // Simulate Supabase emitting signedIn immediately during signUp.
      authStream.add(testUser);
      return const Ok(testUser);
    });

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) => upsertCompleter.future);

    final future = provider.completeSignUp(
      const SignUpParams(
        email: 'ali@example.com',
        password: 'secret',
        name: 'علي',
        username: 'ali',
        location: 'صنعاء',
      ),
    );

    await Future<void>.delayed(Duration.zero);
    // Still unauthenticated while profile upsert is in flight.
    expect(provider.status, AuthStatus.unauthenticated);
    expect(provider.isBusy, isTrue);

    upsertCompleter.complete(const Ok(null));
    final ok = await future;

    expect(ok, isTrue);
    expect(provider.status, AuthStatus.authenticated);
    expect(provider.currentUser, testUser);
    expect(provider.warnings, isEmpty);
  });

  test('completeSignUp exposes non-fatal warnings from outcome', () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'secret',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Ok(testUser));

    when(
      () => profileRepo.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/a.png',
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('storage down')));

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final ok = await provider.completeSignUp(
      const SignUpParams(
        email: 'ali@example.com',
        password: 'secret',
        name: 'علي',
        username: 'ali',
        location: 'صنعاء',
        avatarPath: '/tmp/a.png',
      ),
    );

    expect(ok, isTrue);
    expect(provider.warnings, ['حدث خطأ أثناء رفع الصورة: storage down']);
    expect(provider.status, AuthStatus.authenticated);
  });

  test('signOut sets unauthenticated on success and exposes failure on error',
      () async {
    provider.start();
    authStream.add(testUser);
    await Future<void>.delayed(Duration.zero);
    expect(provider.status, AuthStatus.authenticated);

    when(() => authRepo.signOut()).thenAnswer((_) async => const Ok(null));
    final ok = await provider.signOut();
    expect(ok, isTrue);
    expect(provider.status, AuthStatus.unauthenticated);
    expect(provider.currentUser, isNull);
  });
}
