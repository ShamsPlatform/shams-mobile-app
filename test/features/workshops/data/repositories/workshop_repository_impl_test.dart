import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/repositories/workshop_repository_impl.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

class MockWorkshopRemoteDataSource extends Mock
    implements WorkshopRemoteDataSource {}

void main() {
  late MockWorkshopRemoteDataSource remote;
  late WorkshopRepositoryImpl repository;

  const createParams = CreateWorkshopParams(
    name: 'Shams Solar',
    city: 'صنعاء',
    address: 'صنعاء',
    description: 'Desc',
    handle: '@shams',
  );
  const updateParams = UpdateWorkshopParams(
    workshopId: 'w1',
    name: 'New Name',
  );

  setUpAll(() {
    registerFallbackValue(createParams);
    registerFallbackValue(updateParams);
  });

  setUp(() {
    remote = MockWorkshopRemoteDataSource();
    repository = WorkshopRepositoryImpl(remote);
  });

  group('getPublicWorkshops', () {
    test('maps rows and merges per-workshop isFollowing state', () async {
      when(
        () => remote.fetchPublicWorkshops(
          cityFilter: null,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer(
        (_) async => [
          {'id': 'w1', 'owner_id': 'u1', 'name': 'W1'},
          {'id': 'w2', 'owner_id': 'u2', 'name': 'W2'},
        ],
      );
      when(() => remote.isFollowing('w1')).thenAnswer((_) async => true);
      when(() => remote.isFollowing('w2')).thenAnswer((_) async => false);

      final result = await repository.getPublicWorkshops();

      expect(result, isA<Ok<List<Workshop>>>());
      final workshops = (result as Ok<List<Workshop>>).data;
      expect(workshops, hasLength(2));
      expect(workshops[0].isFollowing, isTrue);
      expect(workshops[1].isFollowing, isFalse);
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => remote.fetchPublicWorkshops(
          cityFilter: any(named: 'cityFilter'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(const ServerException('db error'));

      final result = await repository.getPublicWorkshops();

      expect(result, isA<Err<List<Workshop>>>());
      expect((result as Err<List<Workshop>>).failure, const ServerFailure('db error'));
    });
  });

  group('getMyWorkshop', () {
    test('returns Ok(null) when user has no workshop', () async {
      when(() => remote.fetchMyWorkshop('u1')).thenAnswer((_) async => null);

      final result = await repository.getMyWorkshop(userId: 'u1');

      expect((result as Ok<MyWorkshop?>).data, isNull);
      verifyNever(() => remote.fetchFollowersCount(any()));
    });

    test('fetches followers count and maps MyWorkshop', () async {
      when(() => remote.fetchMyWorkshop('u1')).thenAnswer(
        (_) async => {'id': 'w1', 'owner_id': 'u1', 'name': 'Mine'},
      );
      when(() => remote.fetchFollowersCount('w1')).thenAnswer((_) async => 9);

      final result = await repository.getMyWorkshop(
        userId: 'u1',
        fallbackUsername: 'owner',
      );

      final w = (result as Ok<MyWorkshop?>).data!;
      expect(w.id, 'w1');
      expect(w.username, 'owner');
      expect(w.followersCount, 9);
    });

    test('falls back to 0 followers if followers query fails', () async {
      when(() => remote.fetchMyWorkshop('u1')).thenAnswer(
        (_) async => {'id': 'w1', 'owner_id': 'u1', 'name': 'Mine'},
      );
      when(() => remote.fetchFollowersCount('w1'))
          .thenThrow(const ServerException('count failed'));

      final result = await repository.getMyWorkshop(userId: 'u1');

      final w = (result as Ok<MyWorkshop?>).data!;
      expect(w.followersCount, 0);
    });
  });

  group('mutations and unused methods', () {
    test('createWorkshop maps returned row and propagates AuthFailure', () async {
      when(() => remote.createWorkshop(createParams)).thenAnswer(
        (_) async => {'id': 'w1', 'owner_id': 'u1', 'name': 'Shams Solar'},
      );

      final ok = await repository.createWorkshop(createParams);
      expect((ok as Ok<MyWorkshop>).data.id, 'w1');

      when(() => remote.createWorkshop(createParams))
          .thenThrow(const AppAuthException('not logged in'));
      final err = await repository.createWorkshop(createParams);
      expect((err as Err<MyWorkshop>).failure, isA<AuthFailure>());
    });

    test('updateWorkshop, uploadWorkshopImage, follow, unfollow, getById, delete', () async {
      when(() => remote.updateWorkshop(updateParams)).thenAnswer((_) async {});
      when(
        () => remote.uploadWorkshopImage(
          storagePath: 'u1/logo.jpg',
          localFilePath: '/tmp/a.jpg',
        ),
      ).thenAnswer((_) async => 'https://cdn/logo.jpg');
      when(() => remote.followWorkshop('w1')).thenAnswer((_) async {});
      when(() => remote.unfollowWorkshop('w1')).thenAnswer((_) async {});
      when(() => remote.fetchWorkshopById('w1')).thenAnswer(
        (_) async => {
          'id': 'w1',
          'owner_id': 'u1',
          'name': 'W1',
          'reviews': [
            {
              'id': 'r1',
              'rating': 5,
              'comment': 'Great',
              'created_at': '2026-11-15T00:00:00.000Z',
              'profiles': {'id': 'u2', 'name': 'Ali'},
            }
          ],
        },
      );
      when(() => remote.isFollowing('w1')).thenAnswer((_) async => true);
      when(() => remote.deleteWorkshop('w1')).thenAnswer((_) async {});

      expect(await repository.updateWorkshop(updateParams), isA<Ok<void>>());
      expect(
        ((await repository.uploadWorkshopImage(
          storagePath: 'u1/logo.jpg',
          localFilePath: '/tmp/a.jpg',
        )) as Ok<String>)
            .data,
        'https://cdn/logo.jpg',
      );
      expect(await repository.followWorkshop('w1'), isA<Ok<void>>());
      expect(await repository.unfollowWorkshop('w1'), isA<Ok<void>>());
      final byId = (await repository.getWorkshopById('w1')) as Ok<Workshop?>;
      expect(byId.data?.reviews.single.id, 'r1');
      expect(await repository.deleteWorkshop('w1'), isA<Ok<void>>());
    });
  });
}
