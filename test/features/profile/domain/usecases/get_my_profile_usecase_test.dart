import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/default_profile.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockAuthRepository authRepo;
  late _MockProfileRepository profileRepo;
  late GetMyProfileUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const DefaultProfile(
        id: 'id',
        name: 'name',
        username: 'user',
        email: 'a@b.c',
      ),
    );
  });

  setUp(() {
    authRepo = _MockAuthRepository();
    profileRepo = _MockProfileRepository();
    useCase = GetMyProfileUseCase(authRepo, profileRepo);
  });

  test('returns AuthFailure when no user is signed in', () async {
    when(() => authRepo.currentUser).thenReturn(null);

    final result = await useCase(const NoParams());

    expect(result, isA<Err<AppUser>>());
    expect((result as Err<AppUser>).failure, isA<AuthFailure>());
    verifyZeroInteractions(profileRepo);
  });

  test('returns existing profile and overrides email from auth session',
      () async {
    when(() => authRepo.currentUser).thenReturn(
      const AuthUser(
        id: 'u-12345',
        email: 'new@example.com',
        displayName: 'Auth Name',
      ),
    );
    when(() => profileRepo.getProfile('u-12345')).thenAnswer(
      (_) async => const Ok(
        AppUser(
          id: 'u-12345',
          name: 'Ali',
          email: 'stale@example.com',
          username: 'ali',
          hasWorkshop: true,
        ),
      ),
    );

    final result = await useCase(const NoParams());

    expect(
      result,
      const Ok(
        AppUser(
          id: 'u-12345',
          name: 'Ali',
          email: 'new@example.com',
          username: 'ali',
          hasWorkshop: true,
        ),
      ),
    );
    verifyNever(() => profileRepo.createDefaultProfile(any()));
  });

  test('creates default profile from email and displayName when row is missing',
      () async {
    when(() => authRepo.currentUser).thenReturn(
      const AuthUser(
        id: 'abcdef123',
        email: 'sara@example.com',
        displayName: 'سارة',
      ),
    );

    var callCount = 0;
    when(() => profileRepo.getProfile('abcdef123')).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) return const Ok(null);
      return const Ok(
        AppUser(
          id: 'abcdef123',
          name: 'سارة',
          email: 'sara@example.com',
          username: 'sara',
        ),
      );
    });
    when(() => profileRepo.createDefaultProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final result = await useCase(const NoParams());

    expect(result, isA<Ok<AppUser>>());
    verify(
      () => profileRepo.createDefaultProfile(
        const DefaultProfile(
          id: 'abcdef123',
          name: 'سارة',
          username: 'sara',
          email: 'sara@example.com',
          hasWorkshop: false,
        ),
      ),
    ).called(1);
  });

  test('falls back to user_<id5> username and default Arabic name when missing',
      () async {
    when(() => authRepo.currentUser).thenReturn(
      const AuthUser(
        id: '98765xyz',
        email: null,
        displayName: null,
      ),
    );

    var callCount = 0;
    when(() => profileRepo.getProfile('98765xyz')).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) return const Ok(null);
      return const Ok(
        AppUser(
          id: '98765xyz',
          name: 'مستخدم شمس',
          email: '',
          username: 'user_98765',
        ),
      );
    });
    when(() => profileRepo.createDefaultProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final result = await useCase(const NoParams());

    expect(result, isA<Ok<AppUser>>());
    verify(
      () => profileRepo.createDefaultProfile(
        const DefaultProfile(
          id: '98765xyz',
          name: 'مستخدم شمس',
          username: 'user_98765',
          email: '',
          hasWorkshop: false,
        ),
      ),
    ).called(1);
  });
}
