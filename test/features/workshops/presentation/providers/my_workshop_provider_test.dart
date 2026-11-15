import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_workshop_posts_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/create_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_my_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/upload_workshop_image_usecase.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';

class MockGetMyWorkshopUseCase extends Mock implements GetMyWorkshopUseCase {}

class MockGetWorkshopPostsUseCase extends Mock
    implements GetWorkshopPostsUseCase {}

class MockCreateWorkshopUseCase extends Mock implements CreateWorkshopUseCase {}

class MockUpdateWorkshopUseCase extends Mock implements UpdateWorkshopUseCase {}

class MockUploadWorkshopImageUseCase extends Mock
    implements UploadWorkshopImageUseCase {}

class MockDeletePostUseCase extends Mock implements DeletePostUseCase {}

void main() {
  late MockGetMyWorkshopUseCase getMyWorkshop;
  late MockGetWorkshopPostsUseCase getWorkshopPosts;
  late MockCreateWorkshopUseCase createWorkshop;
  late MockUpdateWorkshopUseCase updateWorkshop;
  late MockUploadWorkshopImageUseCase uploadWorkshopImage;
  late MockDeletePostUseCase deletePost;
  late List<(MyWorkshop?, List<Post>, String?, String?)> syncedCalls;
  late int reloadDirectoryCalls;
  late MyWorkshopProvider provider;

  const sampleWorkshop = MyWorkshop(
    id: 'w1',
    ownerId: 'u1',
    name: 'Shams Solar',
    username: 'shams',
    city: 'صنعاء',
    description: 'Solar installer',
    logoUrl: 'https://cdn.example.com/logo.png',
    coverUrl: 'https://cdn.example.com/cover.png',
    galleryUrls: ['https://cdn.example.com/g1.png'],
    yearsOfExperience: 5,
    followersCount: 12,
    rating: 4.7,
    reviewCount: 9,
  );
  final post1 = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Post 1',
    createdAt: DateTime(2026, 1, 1),
  );
  final post2 = Post(
    id: 'p2',
    workshopId: 'w1',
    textDetails: 'Post 2',
    createdAt: DateTime(2026, 1, 2),
  );

  setUpAll(() {
    registerFallbackValue(const GetMyWorkshopParams());
    registerFallbackValue(const GetWorkshopPostsParams(workshopId: 'w1'));
    registerFallbackValue(
      const CreateWorkshopParams(
        name: 'Shams',
        city: 'صنعاء',
        address: 'صنعاء',
        description: 'desc',
        handle: '@shams',
      ),
    );
    registerFallbackValue(const UpdateWorkshopParams(workshopId: 'w1'));
    registerFallbackValue(
      const UploadWorkshopImageParams(
        ownerId: 'u1',
        kind: WorkshopImageKind.logo,
        localFilePath: '/tmp/a.jpg',
      ),
    );
  });

  setUp(() {
    getMyWorkshop = MockGetMyWorkshopUseCase();
    getWorkshopPosts = MockGetWorkshopPostsUseCase();
    createWorkshop = MockCreateWorkshopUseCase();
    updateWorkshop = MockUpdateWorkshopUseCase();
    uploadWorkshopImage = MockUploadWorkshopImageUseCase();
    deletePost = MockDeletePostUseCase();
    syncedCalls = [];
    reloadDirectoryCalls = 0;

    provider = MyWorkshopProvider(
      getMyWorkshop: getMyWorkshop,
      getWorkshopPosts: getWorkshopPosts,
      createWorkshop: createWorkshop,
      updateWorkshop: updateWorkshop,
      uploadWorkshopImage: uploadWorkshopImage,
      deletePost: deletePost,
      onSyncWorkshop: (w, posts, {pendingLogoPath, pendingCoverPath}) {
        syncedCalls.add((w, List<Post>.from(posts), pendingLogoPath, pendingCoverPath));
      },
      onReloadDirectory: () async {
        reloadDirectoryCalls++;
      },
    );
  });

  Future<void> seedWorkshop() async {
    when(
      () => getMyWorkshop(any()),
    ).thenAnswer((_) async => const Ok(sampleWorkshop));
    await provider.load(userId: 'u1', fallbackUsername: 'shams');
    syncedCalls.clear();
  }

  group('load & loadPosts', () {
    test('loads workshop, syncs public provider, and sets ViewStatus.success', () async {
      when(
        () => getMyWorkshop(any()),
      ).thenAnswer((_) async => const Ok(sampleWorkshop));

      await provider.load(userId: 'u1', fallbackUsername: 'shams');

      expect(provider.status, ViewStatus.success);
      expect(provider.myWorkshop, sampleWorkshop);
      expect(provider.followersCount, 12);
      expect(provider.errorMessage, isNull);
      expect(syncedCalls.last.$1, sampleWorkshop);
    });

    test('sets ViewStatus.failure and errorMessage on load failure', () async {
      when(
        () => getMyWorkshop(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('load failed')));

      await provider.load();

      expect(provider.status, ViewStatus.failure);
      expect(provider.errorMessage, 'load failed');
    });

    test('loadPosts populates posts and syncs public provider', () async {
      await seedWorkshop();
      when(
        () => getWorkshopPosts(any()),
      ).thenAnswer((_) async => Ok([post1, post2]));

      await provider.loadPosts('w1');

      expect(provider.posts, [post1, post2]);
      expect(provider.postCount, 2);
      expect(provider.errorMessage, isNull);
      expect(syncedCalls.last.$2, [post1, post2]);
    });
  });

  group('create', () {
    test('stores created workshop, syncs public, and reloads directory on Ok', () async {
      when(
        () => createWorkshop(any()),
      ).thenAnswer((_) async => const Ok(sampleWorkshop));

      const params = CreateWorkshopParams(
        name: 'Shams Solar',
        city: 'صنعاء',
        address: 'صنعاء',
        description: 'Solar installer',
        handle: '@shams',
      );
      final created = await provider.create(params);

      expect(created, sampleWorkshop);
      expect(provider.status, ViewStatus.success);
      expect(provider.myWorkshop, sampleWorkshop);
      expect(reloadDirectoryCalls, 1);
      expect(syncedCalls.last.$1, sampleWorkshop);
    });

    test('returns null and sets failure state on Err', () async {
      when(
        () => createWorkshop(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('create failed')));

      final created = await provider.create(
        const CreateWorkshopParams(
          name: 'Shams Solar',
          city: 'صنعاء',
          address: 'صنعاء',
          description: 'Solar installer',
          handle: '@shams',
        ),
      );

      expect(created, isNull);
      expect(provider.status, ViewStatus.failure);
      expect(provider.errorMessage, 'create failed');
      expect(reloadDirectoryCalls, 0);
    });
  });

  group('updateInfo', () {
    test('optimistically updates and strips @ from username on Ok', () async {
      await seedWorkshop();
      when(() => updateWorkshop(any())).thenAnswer((_) async => const Ok(null));

      final ok = await provider.updateInfo(
        name: '  New Name  ',
        username: '@new_handle',
        city: 'عدن',
        description: 'New bio',
        yearsOfExperience: 8,
      );

      expect(ok, isTrue);
      expect(provider.myWorkshop?.name, 'New Name');
      expect(provider.myWorkshop?.username, 'new_handle');
      expect(provider.myWorkshop?.city, 'عدن');
      expect(provider.myWorkshop?.description, 'New bio');
      expect(provider.myWorkshop?.yearsOfExperience, 8);
      expect(syncedCalls.last.$1?.name, 'New Name');
    });

    test('reverts optimistic changes and stores errorMessage on Err', () async {
      await seedWorkshop();
      when(
        () => updateWorkshop(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('update failed')));

      final ok = await provider.updateInfo(name: 'Bad Name');

      expect(ok, isFalse);
      expect(provider.myWorkshop, sampleWorkshop);
      expect(provider.errorMessage, 'update failed');
      expect(syncedCalls.last.$1, sampleWorkshop);
    });
  });

  group('images', () {
    test('uploadAndSetCover uploads, updates URL, and clears pending path on Ok', () async {
      await seedWorkshop();
      when(
        () => uploadWorkshopImage(any()),
      ).thenAnswer((_) async => const Ok('https://cdn.example.com/new_cover.png'));
      when(() => updateWorkshop(any())).thenAnswer((_) async => const Ok(null));

      final ok = await provider.uploadAndSetCover('/tmp/cover.jpg');

      expect(ok, isTrue);
      expect(provider.pendingCoverPath, isNull);
      expect(provider.myWorkshop?.coverUrl, 'https://cdn.example.com/new_cover.png');
      expect(syncedCalls.first.$4, '/tmp/cover.jpg');
      expect(syncedCalls.last.$4, isNull);
    });

    test('uploadAndSetLogo clears pending path and keeps previous URL on upload Err', () async {
      await seedWorkshop();
      when(
        () => uploadWorkshopImage(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('upload failed')));

      final ok = await provider.uploadAndSetLogo('/tmp/logo.jpg');

      expect(ok, isFalse);
      expect(provider.pendingLogoPath, isNull);
      expect(provider.myWorkshop?.logoUrl, sampleWorkshop.logoUrl);
      expect(provider.errorMessage, 'upload failed');
      verifyNever(() => updateWorkshop(any()));
    });

    test('uploadAndAddGalleryImage appends URL and removes pending path', () async {
      await seedWorkshop();
      when(
        () => uploadWorkshopImage(any()),
      ).thenAnswer((_) async => const Ok('https://cdn.example.com/g2.png'));
      when(() => updateWorkshop(any())).thenAnswer((_) async => const Ok(null));

      final ok = await provider.uploadAndAddGalleryImage('/tmp/g2.jpg');

      expect(ok, isTrue);
      expect(provider.pendingGalleryPaths, isEmpty);
      expect(
        provider.myWorkshop?.galleryUrls,
        ['https://cdn.example.com/g1.png', 'https://cdn.example.com/g2.png'],
      );
    });

    test('removeGalleryImageAt removes remote image and reverts on Err', () async {
      await seedWorkshop();
      when(
        () => updateWorkshop(any()),
      ).thenAnswer((_) async => const Err(ServerFailure('remove failed')));

      final ok = await provider.removeGalleryImageAt(0);

      expect(ok, isFalse);
      expect(provider.myWorkshop?.galleryUrls, ['https://cdn.example.com/g1.png']);
      expect(provider.errorMessage, 'remove failed');
    });
  });

  group('posts', () {
    test('addPost prepends post and updatePost replaces matching post', () async {
      await seedWorkshop();
      provider.addPost(post1);
      provider.addPost(post2);

      expect(provider.posts, [post2, post1]);

      final edited = post1.copyWith(textDetails: 'Edited 1');
      provider.updatePost(edited);

      expect(provider.posts, [post2, edited]);
      expect(syncedCalls.last.$2, [post2, edited]);
    });

    test('deletePost removes post only on Ok and preserves on Err', () async {
      await seedWorkshop();
      provider.addPost(post1);
      when(
        () => deletePost('p1'),
      ).thenAnswer((_) async => const Err(ServerFailure('delete failed')));

      final fail = await provider.deletePost('p1');
      expect(fail, isFalse);
      expect(provider.posts, [post1]);
      expect(provider.errorMessage, 'delete failed');

      when(() => deletePost('p1')).thenAnswer((_) async => const Ok(null));

      final success = await provider.deletePost('p1');
      expect(success, isTrue);
      expect(provider.posts, isEmpty);
    });
  });

  group('reset', () {
    test('clears workshop, posts, pending paths, and notifies public sync with null', () async {
      await seedWorkshop();
      provider.addPost(post1);
      syncedCalls.clear();

      provider.reset();

      expect(provider.myWorkshop, isNull);
      expect(provider.posts, isEmpty);
      expect(provider.status, ViewStatus.initial);
      expect(provider.errorMessage, isNull);
      expect(syncedCalls.last.$1, isNull);
      expect(syncedCalls.last.$2, isEmpty);
    });
  });
}
