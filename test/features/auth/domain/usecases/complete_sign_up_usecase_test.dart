import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockAuthRepository authRepo;
  late _MockProfileRepository profileRepo;
  late CompleteSignUpUseCase useCase;

  const createdUser = AuthUser(
    id: 'user-123',
    email: 'ali@example.com',
    displayName: 'علي',
  );

  const baseParams = SignUpParams(
    email: ' ali@example.com ',
    password: 'password123',
    name: ' علي ',
    username: ' ali ',
    location: 'صنعاء',
    phone: ' 777000111 ',
    bio: ' مهندس ',
    avatarPath: '/tmp/avatar.png',
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
    useCase = CompleteSignUpUseCase(authRepo, profileRepo);
  });

  test('completes full sign-up flow with avatar and profile without warnings',
      () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'password123',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Ok(createdUser));

    when(
      () => profileRepo.uploadAvatar(
        userId: 'user-123',
        localFilePath: '/tmp/avatar.png',
      ),
    ).thenAnswer((_) async => const Ok('https://cdn.example.com/avatar.png'));

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final result = await useCase(baseParams);

    expect(result, isA<Ok<SignUpOutcome>>());
    final outcome = (result as Ok<SignUpOutcome>).data;
    expect(outcome.user, createdUser);
    expect(outcome.warnings, isEmpty);

    verify(
      () => profileRepo.upsertProfile(
        const ProfileUpsert(
          id: 'user-123',
          name: 'علي',
          username: 'ali',
          location: 'صنعاء',
          email: 'ali@example.com',
          phone: '777000111',
          bio: 'مهندس',
          profileImageUrl: 'https://cdn.example.com/avatar.png',
        ),
      ),
    ).called(1);
  });

  test('skips avatar upload when avatarPath is null or empty', () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'password123',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Ok(createdUser));

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final result = await useCase(
      const SignUpParams(
        email: 'ali@example.com',
        password: 'password123',
        name: 'علي',
        username: 'ali',
        location: 'صنعاء',
      ),
    );

    expect(result, isA<Ok<SignUpOutcome>>());
    final outcome = (result as Ok<SignUpOutcome>).data;
    expect(outcome.warnings, isEmpty);
    verifyNever(
      () => profileRepo.uploadAvatar(
        userId: any(named: 'userId'),
        localFilePath: any(named: 'localFilePath'),
      ),
    );
  });

  test('stops and returns Err when authRepo.signUp fails', () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'password123',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Err(AuthFailure('فشل إنشاء الحساب')));

    final result = await useCase(baseParams);

    expect(result, isA<Err<SignUpOutcome>>());
    expect((result as Err<SignUpOutcome>).failure, const AuthFailure('فشل إنشاء الحساب'));
    verifyZeroInteractions(profileRepo);
  });

  test('continues profile upsert with warning when avatar upload fails',
      () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'password123',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Ok(createdUser));

    when(
      () => profileRepo.uploadAvatar(
        userId: 'user-123',
        localFilePath: '/tmp/avatar.png',
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('upload error')));

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) async => const Ok(null));

    final result = await useCase(baseParams);

    expect(result, isA<Ok<SignUpOutcome>>());
    final outcome = (result as Ok<SignUpOutcome>).data;
    expect(outcome.user, createdUser);
    expect(outcome.warnings, ['حدث خطأ أثناء رفع الصورة: upload error']);

    verify(
      () => profileRepo.upsertProfile(
        const ProfileUpsert(
          id: 'user-123',
          name: 'علي',
          username: 'ali',
          location: 'صنعاء',
          email: 'ali@example.com',
          phone: '777000111',
          bio: 'مهندس',
          profileImageUrl: null,
        ),
      ),
    ).called(1);
  });

  test('returns Ok with warning when profile upsert fails', () async {
    when(
      () => authRepo.signUp(
        email: 'ali@example.com',
        password: 'password123',
        fullName: 'علي',
      ),
    ).thenAnswer((_) async => const Ok(createdUser));

    when(
      () => profileRepo.uploadAvatar(
        userId: 'user-123',
        localFilePath: '/tmp/avatar.png',
      ),
    ).thenAnswer((_) async => const Ok('https://cdn.example.com/avatar.png'));

    when(() => profileRepo.upsertProfile(any()))
        .thenAnswer((_) async => const Err(ServerFailure('db down')));

    final result = await useCase(baseParams);

    expect(result, isA<Ok<SignUpOutcome>>());
    final outcome = (result as Ok<SignUpOutcome>).data;
    expect(outcome.user, createdUser);
    expect(outcome.warnings, ['حدث خطأ أثناء تحديث بيانات الملف: db down']);
  });
}
