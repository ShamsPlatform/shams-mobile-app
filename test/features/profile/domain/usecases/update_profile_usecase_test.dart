import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_update.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockAuthRepository authRepo;
  late _MockProfileRepository profileRepo;
  late UpdateProfileUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const ProfileUpdate(
        name: 'name',
        username: 'username',
        phone: '777',
        bio: 'bio',
      ),
    );
  });

  setUp(() {
    authRepo = _MockAuthRepository();
    profileRepo = _MockProfileRepository();
    useCase = UpdateProfileUseCase(authRepo, profileRepo);
  });

  test('returns AuthFailure when no user is signed in', () async {
    when(() => authRepo.currentUser).thenReturn(null);

    final result = await useCase(
      const UpdateProfileParams(
        name: 'Ali',
        username: 'ali',
        phone: '777',
        bio: 'bio',
      ),
    );

    expect(result, isA<Err<AppUser>>());
    expect((result as Err<AppUser>).failure, isA<AuthFailure>());
    verifyZeroInteractions(profileRepo);
  });

  test('stops with avatar failure message when uploadAvatar fails', () async {
    when(() => authRepo.currentUser).thenReturn(
      const AuthUser(id: 'u-1', email: 'ali@example.com'),
    );
    when(
      () => profileRepo.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/avatar.png',
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('timeout')));

    final result = await useCase(
      const UpdateProfileParams(
        name: 'Ali',
        username: 'ali',
        phone: '777',
        bio: 'bio',
        newAvatarPath: '/tmp/avatar.png',
      ),
    );

    expect(
      result,
      const Err<AppUser>(ServerFailure('فشل رفع الصورة: timeout')),
    );
    verifyNever(() => profileRepo.updateProfile(any(), any()));
  });

  test('uploads avatar, updates row, and returns refreshed AppUser', () async {
    when(() => authRepo.currentUser).thenReturn(
      const AuthUser(id: 'u-1', email: 'ali@example.com'),
    );
    when(
      () => profileRepo.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/avatar.png',
      ),
    ).thenAnswer((_) async => const Ok('https://cdn.example.com/u-1.png'));
    when(() => profileRepo.updateProfile('u-1', any()))
        .thenAnswer((_) async => const Ok(null));
    when(() => profileRepo.getProfile('u-1')).thenAnswer(
      (_) async => const Ok(
        AppUser(
          id: 'u-1',
          name: 'علي الجديد',
          email: 'old@example.com',
          username: 'ali_new',
          phone: '777',
          bio: 'مهندس',
          location: 'صنعاء',
          profileImageUrl: 'https://cdn.example.com/u-1.png',
          hasWorkshop: true,
        ),
      ),
    );

    final result = await useCase(
      const UpdateProfileParams(
        name: ' علي الجديد ',
        username: ' ali_new ',
        phone: ' 777 ',
        bio: ' مهندس ',
        location: 'صنعاء',
        newAvatarPath: '/tmp/avatar.png',
      ),
    );

    verify(
      () => profileRepo.updateProfile(
        'u-1',
        const ProfileUpdate(
          name: 'علي الجديد',
          username: 'ali_new',
          phone: '777',
          bio: 'مهندس',
          location: 'صنعاء',
          profileImageUrl: 'https://cdn.example.com/u-1.png',
        ),
      ),
    ).called(1);

    expect(
      result,
      const Ok(
        AppUser(
          id: 'u-1',
          name: 'علي الجديد',
          email: 'ali@example.com',
          username: 'ali_new',
          phone: '777',
          bio: 'مهندس',
          location: 'صنعاء',
          profileImageUrl: 'https://cdn.example.com/u-1.png',
          hasWorkshop: true,
        ),
      ),
    );
  });
}
