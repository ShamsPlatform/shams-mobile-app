import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/create_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_my_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_public_workshops_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/toggle_follow_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/upload_workshop_image_usecase.dart';

class MockWorkshopRepository extends Mock implements WorkshopRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockWorkshopRepository workshopRepo;
  late MockAuthRepository authRepo;

  const authUser = AuthUser(id: 'u1', email: 'u1@example.com');
  const sampleWorkshop = Workshop(
    id: 'w1',
    ownerId: 'u1',
    name: 'Shams Solar',
    handle: '@shams',
    city: 'صنعاء',
  );
  const sampleMyWorkshop = MyWorkshop(
    id: 'w1',
    ownerId: 'u1',
    name: 'Shams Solar',
    username: 'shams',
    city: 'صنعاء',
    followersCount: 12,
  );
  const createParams = CreateWorkshopParams(
    name: 'Shams Solar',
    city: 'صنعاء',
    address: 'صنعاء',
    description: 'Solar systems',
    handle: '@shams',
  );
  const updateParams = UpdateWorkshopParams(
    workshopId: 'w1',
    name: 'Updated Solar',
  );

  setUpAll(() {
    registerFallbackValue(createParams);
    registerFallbackValue(updateParams);
  });

  setUp(() {
    workshopRepo = MockWorkshopRepository();
    authRepo = MockAuthRepository();
  });

  group('GetPublicWorkshopsUseCase', () {
    test('delegates filter and pagination arguments to repository', () async {
      when(
        () => workshopRepo.getPublicWorkshops(
          cityFilter: 'صنعاء',
          limit: 10,
          offset: 20,
        ),
      ).thenAnswer((_) async => const Ok([sampleWorkshop]));

      final useCase = GetPublicWorkshopsUseCase(workshopRepo);
      final result = await useCase(
        const GetPublicWorkshopsParams(
          cityFilter: 'صنعاء',
          limit: 10,
          offset: 20,
        ),
      );

      expect(result, isA<Ok<List<Workshop>>>());
      expect((result as Ok<List<Workshop>>).data, [sampleWorkshop]);
      verify(
        () => workshopRepo.getPublicWorkshops(
          cityFilter: 'صنعاء',
          limit: 10,
          offset: 20,
        ),
      ).called(1);
    });
  });

  group('GetMyWorkshopUseCase', () {
    test('returns AuthFailure when no userId is provided or signed in', () async {
      when(() => authRepo.currentUser).thenReturn(null);
      final useCase = GetMyWorkshopUseCase(workshopRepo, authRepo);

      final result = await useCase(const GetMyWorkshopParams());

      expect(result, isA<Err<MyWorkshop?>>());
      expect((result as Err<MyWorkshop?>).failure, isA<AuthFailure>());
      verifyNever(
        () => workshopRepo.getMyWorkshop(
          userId: any(named: 'userId'),
          fallbackUsername: any(named: 'fallbackUsername'),
        ),
      );
    });

    test('uses auth currentUser id when params.userId is null', () async {
      when(() => authRepo.currentUser).thenReturn(authUser);
      when(
        () => workshopRepo.getMyWorkshop(
          userId: 'u1',
          fallbackUsername: 'fallback',
        ),
      ).thenAnswer((_) async => const Ok(sampleMyWorkshop));

      final useCase = GetMyWorkshopUseCase(workshopRepo, authRepo);
      final result = await useCase(
        const GetMyWorkshopParams(fallbackUsername: 'fallback'),
      );

      expect((result as Ok<MyWorkshop?>).data, sampleMyWorkshop);
    });

    test('prefers explicit params.userId when provided', () async {
      when(
        () => workshopRepo.getMyWorkshop(
          userId: 'u2',
          fallbackUsername: 'owner2',
        ),
      ).thenAnswer((_) async => const Ok(null));

      final useCase = GetMyWorkshopUseCase(workshopRepo, authRepo);
      final result = await useCase(
        const GetMyWorkshopParams(userId: 'u2', fallbackUsername: 'owner2'),
      );

      expect((result as Ok<MyWorkshop?>).data, isNull);
    });
  });

  group('CreateWorkshopUseCase', () {
    test('returns AuthFailure when not authenticated', () async {
      when(() => authRepo.currentUser).thenReturn(null);
      final useCase = CreateWorkshopUseCase(workshopRepo, authRepo);

      final result = await useCase(createParams);

      expect(result, isA<Err<MyWorkshop>>());
      expect((result as Err<MyWorkshop>).failure, isA<AuthFailure>());
      verifyNever(() => workshopRepo.createWorkshop(any()));
    });

    test('delegates to repository when authenticated', () async {
      when(() => authRepo.currentUser).thenReturn(authUser);
      when(() => workshopRepo.createWorkshop(createParams))
          .thenAnswer((_) async => const Ok(sampleMyWorkshop));

      final useCase = CreateWorkshopUseCase(workshopRepo, authRepo);
      final result = await useCase(createParams);

      expect((result as Ok<MyWorkshop>).data, sampleMyWorkshop);
      verify(() => workshopRepo.createWorkshop(createParams)).called(1);
    });
  });

  group('UpdateWorkshopUseCase', () {
    test('short-circuits with Ok when no fields are set', () async {
      final useCase = UpdateWorkshopUseCase(workshopRepo);

      final result = await useCase(const UpdateWorkshopParams(workshopId: 'w1'));

      expect(result, isA<Ok<void>>());
      verifyNever(() => workshopRepo.updateWorkshop(any()));
    });

    test('delegates non-empty update to repository', () async {
      when(() => workshopRepo.updateWorkshop(updateParams))
          .thenAnswer((_) async => const Ok<void>(null));

      final useCase = UpdateWorkshopUseCase(workshopRepo);
      final result = await useCase(updateParams);

      expect(result, isA<Ok<void>>());
      verify(() => workshopRepo.updateWorkshop(updateParams)).called(1);
    });
  });

  group('UploadWorkshopImageUseCase', () {
    test('builds expected storage path for logo, cover, and gallery', () async {
      final fixedTime = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      when(
        () => workshopRepo.uploadWorkshopImage(
          storagePath: any(named: 'storagePath'),
          localFilePath: any(named: 'localFilePath'),
        ),
      ).thenAnswer((_) async => const Ok('https://cdn/img.jpg'));

      final useCase = UploadWorkshopImageUseCase(
        workshopRepo,
        clock: () => fixedTime,
      );

      await useCase(
        const UploadWorkshopImageParams(
          ownerId: 'u1',
          kind: WorkshopImageKind.logo,
          localFilePath: '/tmp/logo.jpg',
        ),
      );
      await useCase(
        const UploadWorkshopImageParams(
          ownerId: 'u1',
          kind: WorkshopImageKind.cover,
          localFilePath: '/tmp/cover.jpg',
        ),
      );
      await useCase(
        const UploadWorkshopImageParams(
          ownerId: 'u1',
          kind: WorkshopImageKind.gallery,
          localFilePath: '/tmp/g.jpg',
        ),
      );

      verify(
        () => workshopRepo.uploadWorkshopImage(
          storagePath: 'u1/logo_edit_1700000000000.jpg',
          localFilePath: '/tmp/logo.jpg',
        ),
      ).called(1);
      verify(
        () => workshopRepo.uploadWorkshopImage(
          storagePath: 'u1/cover_edit_1700000000000.jpg',
          localFilePath: '/tmp/cover.jpg',
        ),
      ).called(1);
      verify(
        () => workshopRepo.uploadWorkshopImage(
          storagePath: 'u1/gallery_1700000000000.jpg',
          localFilePath: '/tmp/g.jpg',
        ),
      ).called(1);
    });
  });

  group('ToggleFollowUseCase', () {
    test('calls unfollowWorkshop when currently following', () async {
      when(() => workshopRepo.unfollowWorkshop('w1'))
          .thenAnswer((_) async => const Ok<void>(null));

      final useCase = ToggleFollowUseCase(workshopRepo);
      final result = await useCase(
        const ToggleFollowParams(workshopId: 'w1', isCurrentlyFollowing: true),
      );

      expect(result, isA<Ok<void>>());
      verify(() => workshopRepo.unfollowWorkshop('w1')).called(1);
      verifyNever(() => workshopRepo.followWorkshop(any()));
    });

    test('calls followWorkshop when not currently following', () async {
      when(() => workshopRepo.followWorkshop('w1'))
          .thenAnswer((_) async => const Ok<void>(null));

      final useCase = ToggleFollowUseCase(workshopRepo);
      final result = await useCase(
        const ToggleFollowParams(workshopId: 'w1', isCurrentlyFollowing: false),
      );

      expect(result, isA<Ok<void>>());
      verify(() => workshopRepo.followWorkshop('w1')).called(1);
      verifyNever(() => workshopRepo.unfollowWorkshop(any()));
    });
  });
}
