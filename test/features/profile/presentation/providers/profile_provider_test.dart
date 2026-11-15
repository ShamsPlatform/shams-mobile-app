import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_update.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthRepository authRepo;
  late _MockProfileRepository profileRepo;
  late ProfileProvider provider;

  const userA = AppUser(
    id: 'u-1',
    name: 'علي',
    email: 'ali@example.com',
    username: 'ali',
    location: 'صنعاء',
    profileImageUrl: 'https://cdn.example.com/old.png',
    hasWorkshop: false,
  );

  const userUpdated = AppUser(
    id: 'u-1',
    name: 'علي المحسن',
    email: 'ali@example.com',
    username: 'ali_m',
    location: 'عدن',
    phone: '777',
    bio: 'مهندس',
    profileImageUrl: 'https://cdn.example.com/new.png',
    hasWorkshop: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const ProfileUpdate(
        name: 'name',
        username: 'user',
        phone: '777',
        bio: 'bio',
      ),
    );
  });

  setUp(() {
    authRepo = _MockAuthRepository();
    profileRepo = _MockProfileRepository();
    provider = ProfileProvider(
      getMyProfile: GetMyProfileUseCase(authRepo, profileRepo),
      updateProfile: UpdateProfileUseCase(authRepo, profileRepo),
    );
  });

  test('starts initial with null currentUser and placeholder fallback', () {
    expect(provider.status, ViewStatus.initial);
    expect(provider.currentUser, isNull);
    expect(provider.currentUserOrPlaceholder.id, isEmpty);
    expect(provider.currentUserOrPlaceholder.name, 'جاري التحميل...');
  });

  test('load populates currentUser on Ok and sets errorMessage on Err',
      () async {
    when(() => authRepo.currentUser)
        .thenReturn(const AuthUser(id: 'u-1', email: 'ali@example.com'));
    when(() => profileRepo.getProfile('u-1'))
        .thenAnswer((_) async => const Ok(userA));

    await provider.load();

    expect(provider.status, ViewStatus.success);
    expect(provider.currentUser, userA);
    expect(provider.currentUserOrPlaceholder, userA);
    expect(provider.errorMessage, isNull);

    when(() => profileRepo.getProfile('u-1'))
        .thenAnswer((_) async => const Err(ServerFailure('network down')));

    await provider.load();

    expect(provider.status, ViewStatus.failure);
    expect(provider.errorMessage, 'network down');
  });

  test('updateProfile updates currentUser on success and preserves error on fail',
      () async {
    when(() => authRepo.currentUser)
        .thenReturn(const AuthUser(id: 'u-1', email: 'ali@example.com'));
    when(() => profileRepo.getProfile('u-1'))
        .thenAnswer((_) async => const Ok(userA));
    await provider.load();

    when(
      () => profileRepo.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/new.png',
      ),
    ).thenAnswer((_) async => const Ok('https://cdn.example.com/new.png'));
    when(() => profileRepo.updateProfile('u-1', any()))
        .thenAnswer((_) async => const Ok(null));
    when(() => profileRepo.getProfile('u-1'))
        .thenAnswer((_) async => const Ok(userUpdated));

    final ok = await provider.updateProfile(
      const UpdateProfileParams(
        name: 'علي المحسن',
        username: 'ali_m',
        phone: '777',
        bio: 'مهندس',
        location: 'عدن',
        newAvatarPath: '/tmp/new.png',
      ),
    );

    expect(ok, isTrue);
    expect(provider.status, ViewStatus.success);
    expect(provider.currentUser, userUpdated);

    when(
      () => profileRepo.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/bad.png',
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('boom')));

    final fail = await provider.updateProfile(
      const UpdateProfileParams(
        name: 'علي',
        username: 'ali',
        phone: '777',
        bio: 'bio',
        newAvatarPath: '/tmp/bad.png',
      ),
    );

    expect(fail, isFalse);
    expect(provider.status, ViewStatus.failure);
    expect(provider.errorMessage, 'فشل رفع الصورة: boom');
  });

  test('updateWorkshopStatus toggles hasWorkshop and reset clears state',
      () async {
    when(() => authRepo.currentUser)
        .thenReturn(const AuthUser(id: 'u-1', email: 'ali@example.com'));
    when(() => profileRepo.getProfile('u-1'))
        .thenAnswer((_) async => const Ok(userA));
    await provider.load();

    provider.updateWorkshopStatus(true);
    expect(provider.currentUser?.hasWorkshop, isTrue);

    provider.reset();
    expect(provider.currentUser, isNull);
    expect(provider.status, ViewStatus.initial);
    expect(provider.errorMessage, isNull);
  });
}
