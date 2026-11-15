import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_workshop_posts_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/hide_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_post_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/update_post_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockAuthRepository authRepo;
  late MockPostRepository postRepo;

  final now = DateTime(2026, 11, 15, 3, 0);
  const authUser = AuthUser(id: 'u1', email: 'u1@example.com');
  const appUser = AppUser(id: 'u1', name: 'Ali', email: 'u1@example.com');
  final samplePost = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Solar panel setup',
    createdAt: now,
    author: appUser,
  );
  final sampleComment = Comment(
    id: 'c1',
    postId: 'p1',
    user: appUser,
    text: 'Great work!',
    createdAt: now,
  );
  const serverFailure = ServerFailure('server error');

  setUp(() {
    authRepo = MockAuthRepository();
    postRepo = MockPostRepository();
  });

  group('GetFeedUseCase', () {
    test('returns AuthFailure when no user is signed in', () async {
      when(() => authRepo.currentUser).thenReturn(null);
      final useCase = GetFeedUseCase(authRepo, postRepo);

      final result = await useCase(const GetFeedParams());

      expect(result, isA<Err<List<Post>>>());
      expect((result as Err<List<Post>>).failure, isA<AuthFailure>());
      verifyZeroInteractions(postRepo);
    });

    test('forwards signed-in user id and pagination on success', () async {
      when(() => authRepo.currentUser).thenReturn(authUser);
      when(
        () => postRepo.fetchFeed(currentUserId: 'u1', limit: 10, offset: 5),
      ).thenAnswer((_) async => Ok([samplePost]));

      final result = await GetFeedUseCase(authRepo, postRepo)(
        const GetFeedParams(limit: 10, offset: 5),
      );

      expect(result, isA<Ok<List<Post>>>());
      expect((result as Ok<List<Post>>).data, equals([samplePost]));
    });

    test('propagates repository failure', () async {
      when(() => authRepo.currentUser).thenReturn(authUser);
      when(
        () => postRepo.fetchFeed(currentUserId: 'u1', limit: 20, offset: 0),
      ).thenAnswer((_) async => const Err(serverFailure));

      final result = await GetFeedUseCase(authRepo, postRepo)(
        const GetFeedParams(),
      );

      expect(result, equals(const Err<List<Post>>(serverFailure)));
    });
  });

  group('GetWorkshopPostsUseCase', () {
    test('returns workshop posts on Ok and failure on Err', () async {
      final useCase = GetWorkshopPostsUseCase(postRepo);
      when(
        () => postRepo.fetchWorkshopPosts(workshopId: 'w1', limit: 20, offset: 0),
      ).thenAnswer((_) async => Ok([samplePost]));

      final okResult = await useCase(
        const GetWorkshopPostsParams(workshopId: 'w1'),
      );
      expect(okResult, isA<Ok<List<Post>>>());
      expect((okResult as Ok<List<Post>>).data, equals([samplePost]));

      when(
        () => postRepo.fetchWorkshopPosts(workshopId: 'w1', limit: 20, offset: 0),
      ).thenAnswer((_) async => const Err(serverFailure));

      expect(
        await useCase(const GetWorkshopPostsParams(workshopId: 'w1')),
        equals(const Err<List<Post>>(serverFailure)),
      );
    });
  });

  group('CreatePostUseCase', () {
    test('creates post on Ok and propagates Err', () async {
      final useCase = CreatePostUseCase(postRepo);
      const params = CreatePostParams(
        workshopId: 'w1',
        textDetails: 'Hello',
        imagePaths: ['/tmp/a.jpg'],
        isHighlighted: true,
      );
      when(
        () => postRepo.createPost(
          workshopId: 'w1',
          textDetails: 'Hello',
          imagePaths: const ['/tmp/a.jpg'],
          isHighlighted: true,
        ),
      ).thenAnswer((_) async => Ok(samplePost));

      expect(await useCase(params), equals(Ok(samplePost)));

      when(
        () => postRepo.createPost(
          workshopId: 'w1',
          textDetails: 'Hello',
          imagePaths: const ['/tmp/a.jpg'],
          isHighlighted: true,
        ),
      ).thenAnswer((_) async => const Err(serverFailure));

      expect(await useCase(params), equals(const Err<Post>(serverFailure)));
    });
  });

  group('UpdatePostUseCase', () {
    test('updates post on Ok and propagates Err', () async {
      final useCase = UpdatePostUseCase(postRepo);
      const params = UpdatePostParams(
        postId: 'p1',
        textDetails: 'Updated',
        isHighlighted: false,
      );
      when(
        () => postRepo.updatePost(
          postId: 'p1',
          textDetails: 'Updated',
          isHighlighted: false,
        ),
      ).thenAnswer((_) async => const Ok(null));

      expect(await useCase(params), isA<Ok<void>>());

      when(
        () => postRepo.updatePost(
          postId: 'p1',
          textDetails: 'Updated',
          isHighlighted: false,
        ),
      ).thenAnswer((_) async => const Err(serverFailure));

      expect(await useCase(params), equals(const Err<void>(serverFailure)));
    });
  });

  group('DeletePostUseCase & HidePostUseCase', () {
    test('DeletePostUseCase delegates Ok and Err', () async {
      final useCase = DeletePostUseCase(postRepo);
      when(() => postRepo.deletePost('p1'))
          .thenAnswer((_) async => const Ok(null));
      expect(await useCase('p1'), isA<Ok<void>>());

      when(() => postRepo.deletePost('p1'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase('p1'), equals(const Err<void>(serverFailure)));
    });

    test('HidePostUseCase delegates Ok and Err', () async {
      final useCase = HidePostUseCase(postRepo);
      when(() => postRepo.hidePost('p1'))
          .thenAnswer((_) async => const Ok(null));
      expect(await useCase('p1'), isA<Ok<void>>());

      when(() => postRepo.hidePost('p1'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase('p1'), equals(const Err<void>(serverFailure)));
    });
  });

  group('TogglePostLikeUseCase', () {
    test('returns bool on Ok and propagates Err', () async {
      final useCase = TogglePostLikeUseCase(postRepo);
      when(() => postRepo.toggleLike('p1'))
          .thenAnswer((_) async => const Ok(true));
      expect(await useCase('p1'), equals(const Ok(true)));

      when(() => postRepo.toggleLike('p1'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase('p1'), equals(const Err<bool>(serverFailure)));
    });
  });

  group('Comment use cases', () {
    test('AddCommentUseCase returns Comment on Ok and propagates Err', () async {
      final useCase = AddCommentUseCase(postRepo);
      const params = AddCommentParams(postId: 'p1', text: 'Great work!');
      when(() => postRepo.addComment(postId: 'p1', text: 'Great work!'))
          .thenAnswer((_) async => Ok(sampleComment));
      expect(await useCase(params), equals(Ok(sampleComment)));

      when(() => postRepo.addComment(postId: 'p1', text: 'Great work!'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase(params), equals(const Err<Comment>(serverFailure)));
    });

    test('DeleteCommentUseCase delegates Ok and Err', () async {
      final useCase = DeleteCommentUseCase(postRepo);
      when(() => postRepo.deleteComment('c1'))
          .thenAnswer((_) async => const Ok(null));
      expect(await useCase('c1'), isA<Ok<void>>());

      when(() => postRepo.deleteComment('c1'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase('c1'), equals(const Err<void>(serverFailure)));
    });

    test('ToggleCommentLikeUseCase returns bool on Ok and propagates Err',
        () async {
      final useCase = ToggleCommentLikeUseCase(postRepo);
      when(() => postRepo.toggleCommentLike('c1'))
          .thenAnswer((_) async => const Ok(false));
      expect(await useCase('c1'), equals(const Ok(false)));

      when(() => postRepo.toggleCommentLike('c1'))
          .thenAnswer((_) async => const Err(serverFailure));
      expect(await useCase('c1'), equals(const Err<bool>(serverFailure)));
    });
  });
}
