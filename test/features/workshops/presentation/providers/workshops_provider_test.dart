import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_public_workshops_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/toggle_follow_usecase.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';

class MockGetPublicWorkshopsUseCase extends Mock
    implements GetPublicWorkshopsUseCase {}

class MockToggleFollowUseCase extends Mock implements ToggleFollowUseCase {}

void main() {
  late MockGetPublicWorkshopsUseCase getPublicWorkshops;
  late MockToggleFollowUseCase toggleFollow;
  late WorkshopsProvider provider;

  const workshop1 = Workshop(
    id: 'w1',
    ownerId: 'u1',
    name: 'Shams Solar',
    handle: '@shams',
    city: 'صنعاء',
    rating: 4.5,
    reviewCount: 10,
    isFollowing: false,
  );
  const workshop2 = Workshop(
    id: 'w2',
    ownerId: 'u2',
    name: 'Aden Energy',
    handle: '@aden',
    city: 'عدن',
    rating: 4.0,
    reviewCount: 3,
    isFollowing: true,
  );
  final samplePost = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Solar post',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(const GetPublicWorkshopsParams());
    registerFallbackValue(
      const ToggleFollowParams(workshopId: 'w1', isCurrentlyFollowing: false),
    );
  });

  setUp(() {
    getPublicWorkshops = MockGetPublicWorkshopsUseCase();
    toggleFollow = MockToggleFollowUseCase();
    provider = WorkshopsProvider(
      getPublicWorkshops: getPublicWorkshops,
      toggleFollow: toggleFollow,
    );
  });

  group('load', () {
    test('populates workshops and sets ViewStatus.success on Ok', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1, workshop2]));

      await provider.load();

      expect(provider.status, ViewStatus.success);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.workshops, [workshop1, workshop2]);
    });

    test('sets ViewStatus.failure and errorMessage on Err', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('network down')));

      await provider.load();

      expect(provider.status, ViewStatus.failure);
      expect(provider.errorMessage, 'network down');
      expect(provider.workshops, isEmpty);
    });
  });

  group('lookups', () {
    test('getWorkshopById and getWorkshopByOwnerId return matches or null', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1, workshop2]));
      await provider.load();

      expect(provider.getWorkshopById('w1'), workshop1);
      expect(provider.getWorkshopById('missing'), isNull);
      expect(provider.getWorkshopByOwnerId('u2'), workshop2);
      expect(provider.getWorkshopByOwnerId('missing'), isNull);
    });
  });

  group('toggleFollow', () {
    test('returns false when workshop is not found', () async {
      final ok = await provider.toggleFollow('missing');

      expect(ok, isFalse);
      verifyNever(() => toggleFollow(any()));
    });

    test('optimistically toggles follow and keeps state on Ok', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1]));
      when(
        () => toggleFollow(any()),
      ).thenAnswer((_) async => const Ok(null));
      await provider.load();

      final ok = await provider.toggleFollow('w1');

      expect(ok, isTrue);
      expect(provider.getWorkshopById('w1')?.isFollowing, isTrue);
      expect(provider.errorMessage, isNull);
      final captured = verify(() => toggleFollow(captureAny())).captured;
      expect(captured, hasLength(1));
      final params = captured.single as ToggleFollowParams;
      expect(params.workshopId, 'w1');
      expect(params.isCurrentlyFollowing, isFalse);
    });

    test('reverts optimistic follow and stores errorMessage on Err', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1]));
      when(
        () => toggleFollow(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('follow failed')));
      await provider.load();

      final ok = await provider.toggleFollow('w1');

      expect(ok, isFalse);
      expect(provider.getWorkshopById('w1')?.isFollowing, isFalse);
      expect(provider.errorMessage, 'follow failed');
    });
  });

  group('applyMyWorkshop', () {
    const myWorkshop = MyWorkshop(
      id: 'w1',
      ownerId: 'u1',
      name: 'Shams Updated',
      username: 'shams_new',
      city: 'تعز',
      description: 'Updated description',
      logoUrl: 'https://cdn.example.com/logo.png',
      coverUrl: 'https://cdn.example.com/cover.png',
      galleryUrls: ['https://cdn.example.com/g1.png'],
      yearsOfExperience: 9,
      followersCount: 15,
      rating: 4.9,
      reviewCount: 22,
    );

    test('patches existing workshop in directory and prefers pending paths', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1]));
      await provider.load();

      provider.applyMyWorkshop(
        myWorkshop,
        [samplePost],
        pendingLogoPath: '/tmp/logo.jpg',
        pendingCoverPath: '/tmp/cover.jpg',
      );

      final updated = provider.getWorkshopById('w1')!;
      expect(updated.name, 'Shams Updated');
      expect(updated.handle, '@shams_new');
      expect(updated.city, 'تعز');
      expect(updated.logoUrl, '/tmp/logo.jpg');
      expect(updated.coverUrl, '/tmp/cover.jpg');
      expect(updated.posts, [samplePost]);
    });

    test('inserts missing workshop at index 0 using DB rating and reviewCount', () {
      const brandNew = MyWorkshop(
        id: 'w3',
        ownerId: 'u3',
        name: 'New Workshop',
        username: 'new_ws',
        city: 'إب',
        rating: 4.2,
        reviewCount: 7,
      );

      provider.applyMyWorkshop(brandNew, [samplePost]);

      expect(provider.workshops, hasLength(1));
      final inserted = provider.workshops.first;
      expect(inserted.id, 'w3');
      expect(inserted.rating, 4.2);
      expect(inserted.reviewCount, 7);
      expect(inserted.posts, [samplePost]);
    });

    test('re-applies synced workshop after load() finishes', () async {
      const brandNew = MyWorkshop(
        id: 'w3',
        ownerId: 'u3',
        name: 'New Workshop',
        username: 'new_ws',
        city: 'إب',
      );
      provider.applyMyWorkshop(brandNew, [samplePost]);

      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1]));
      await provider.load();

      expect(provider.workshops.first.id, 'w3');
      expect(provider.getWorkshopById('w1'), workshop1);
    });
  });

  group('reset and pagination', () {
    test('clears workshops, synced state, status, and errorMessage', () async {
      when(
        () => getPublicWorkshops(any()),
      ).thenAnswer((_) async => const Ok([workshop1]));
      await provider.load();

      provider.reset();

      expect(provider.workshops, isEmpty);
      expect(provider.status, ViewStatus.initial);
      expect(provider.hasMore, isTrue);
      expect(provider.isLoadingMore, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('loadMore appends unique pages and stops on short page', () async {
      final paged = WorkshopsProvider(
        getPublicWorkshops: getPublicWorkshops,
        toggleFollow: toggleFollow,
        pageSize: 1,
      );

      when(
        () => getPublicWorkshops(
          any(
            that: predicate<GetPublicWorkshopsParams>(
              (p) => p.limit == 1 && p.offset == 0,
            ),
          ),
        ),
      ).thenAnswer((_) async => const Ok([workshop1]));
      when(
        () => getPublicWorkshops(
          any(
            that: predicate<GetPublicWorkshopsParams>(
              (p) => p.limit == 1 && p.offset == 1,
            ),
          ),
        ),
      ).thenAnswer((_) async => const Ok([workshop1, workshop2]));
      when(
        () => getPublicWorkshops(
          any(
            that: predicate<GetPublicWorkshopsParams>(
              (p) => p.limit == 1 && p.offset == 3,
            ),
          ),
        ),
      ).thenAnswer((_) async => const Err(ServerFailure('page fail')));

      await paged.load();
      expect(paged.hasMore, isTrue);

      await paged.loadMore();
      expect(paged.workshops.map((w) => w.id), ['w1', 'w2']);

      await paged.loadMore();
      expect(paged.errorMessage, 'page fail');
      expect(paged.workshops.map((w) => w.id), ['w1', 'w2']);

      when(
        () => getPublicWorkshops(
          any(
            that: predicate<GetPublicWorkshopsParams>(
              (p) => p.limit == 1 && p.offset == 3,
            ),
          ),
        ),
      ).thenAnswer((_) async => const Ok([]));

      await paged.loadMore();
      expect(paged.hasMore, isFalse);

      await paged.loadMore();
      verify(() => getPublicWorkshops(any())).called(4);
    });
  });

  group('updateReviewSummary', () {
    test('updates matching workshop rating and reviewCount in directory',
        () async {
      when(() => getPublicWorkshops(any()))
          .thenAnswer((_) async => const Ok([workshop1, workshop2]));
      await provider.load();

      provider.updateReviewSummary('w1', rating: 4.9, reviewCount: 14);
      provider.updateReviewSummary('missing', rating: 3.0, reviewCount: 1);

      final updated = provider.getWorkshopById('w1')!;
      expect(updated.rating, 4.9);
      expect(updated.reviewCount, 14);
      expect(provider.getWorkshopById('w2')!.rating, 4.0);
    });
  });
}
