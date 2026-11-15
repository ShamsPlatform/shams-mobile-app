import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/hide_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_post_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockTogglePostLikeUseCase extends Mock implements TogglePostLikeUseCase {}

class MockAddCommentUseCase extends Mock implements AddCommentUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockToggleCommentLikeUseCase extends Mock
    implements ToggleCommentLikeUseCase {}

class MockHidePostUseCase extends Mock implements HidePostUseCase {}

void main() {
  late MockGetFeedUseCase getFeed;
  late MockTogglePostLikeUseCase toggleLike;
  late MockAddCommentUseCase addComment;
  late MockDeleteCommentUseCase deleteComment;
  late MockToggleCommentLikeUseCase toggleCommentLike;
  late MockHidePostUseCase hidePost;
  late FeedProvider provider;

  final now = DateTime(2026, 11, 15, 4, 0);
  const user = AppUser(id: 'u1', name: 'Ali', email: 'ali@example.com');
  final comment1 = Comment(
    id: 'c1',
    postId: 'p1',
    user: user,
    text: 'Initial',
    likesCount: 2,
    isLiked: false,
    createdAt: now,
  );
  final post1 = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Post 1',
    createdAt: now,
    author: user,
    likesCount: 5,
    isLiked: false,
    comments: [comment1],
  );
  final post2 = Post(
    id: 'p2',
    workshopId: 'w1',
    textDetails: 'Post 2',
    createdAt: now,
  );

  setUpAll(() {
    registerFallbackValue(const GetFeedParams());
    registerFallbackValue(const AddCommentParams(postId: '', text: ''));
  });

  setUp(() {
    getFeed = MockGetFeedUseCase();
    toggleLike = MockTogglePostLikeUseCase();
    addComment = MockAddCommentUseCase();
    deleteComment = MockDeleteCommentUseCase();
    toggleCommentLike = MockToggleCommentLikeUseCase();
    hidePost = MockHidePostUseCase();
    provider = FeedProvider(
      getFeed: getFeed,
      toggleLike: toggleLike,
      addComment: addComment,
      deleteComment: deleteComment,
      toggleCommentLike: toggleCommentLike,
      hidePost: hidePost,
    );
  });

  test('load populates posts on Ok and sets errorMessage on Err', () async {
    when(() => getFeed(any())).thenAnswer((_) async => Ok([post1, post2]));

    await provider.load();

    expect(provider.status, ViewStatus.success);
    expect(provider.posts, [post1, post2]);
    expect(provider.getPostById('p1'), post1);
    expect(provider.getPostById('missing'), isNull);

    when(() => getFeed(any()))
        .thenAnswer((_) async => const Err(ServerFailure('network timeout')));

    await provider.load();

    expect(provider.status, ViewStatus.failure);
    expect(provider.errorMessage, 'network timeout');
  });

  test('toggleLike optimistically updates and reverts with errorMessage on Err',
      () async {
    when(() => getFeed(any())).thenAnswer((_) async => Ok([post1]));
    await provider.load();

    when(() => toggleLike('p1'))
        .thenAnswer((_) async => const Err(ServerFailure('like failed')));

    await provider.toggleLike('p1');

    expect(provider.getPostById('p1')!.isLiked, false);
    expect(provider.getPostById('p1')!.likesCount, 5);
    expect(provider.errorMessage, 'like failed');

    when(() => toggleLike('p1')).thenAnswer((_) async => const Ok(true));
    await provider.toggleLike('p1');

    expect(provider.getPostById('p1')!.isLiked, true);
    expect(provider.getPostById('p1')!.likesCount, 6);
    expect(provider.errorMessage, isNull);
  });

  test('addComment, deleteComment, and toggleCommentLike update and revert properly',
      () async {
    when(() => getFeed(any())).thenAnswer((_) async => Ok([post1]));
    await provider.load();

    final newComment = Comment(
      id: 'c2',
      postId: 'p1',
      user: user,
      text: 'Added',
      createdAt: now,
    );
    when(() => addComment(any())).thenAnswer((_) async => Ok(newComment));

    await provider.addComment('p1', 'Added');
    expect(provider.getPostById('p1')!.comments, [comment1, newComment]);

    when(() => toggleCommentLike('c1'))
        .thenAnswer((_) async => const Err(ServerFailure('comment like err')));
    await provider.toggleCommentLike('p1', 'c1');
    expect(provider.getPostById('p1')!.comments.first.isLiked, false);
    expect(provider.getPostById('p1')!.comments.first.likesCount, 2);
    expect(provider.errorMessage, 'comment like err');

    when(() => deleteComment('c2')).thenAnswer((_) async => const Ok(null));
    await provider.deleteComment('p1', 'c2');
    expect(provider.getPostById('p1')!.comments, [comment1]);

    when(() => deleteComment('c1'))
        .thenAnswer((_) async => const Err(ServerFailure('delete err')));
    await provider.deleteComment('p1', 'c1');
    expect(provider.getPostById('p1')!.comments, [comment1]);
    expect(provider.errorMessage, 'delete err');
  });

  test('hidePost removes optimistically, restores on Err, and reset clears state',
      () async {
    when(() => getFeed(any())).thenAnswer((_) async => Ok([post1, post2]));
    await provider.load();

    when(() => hidePost('p1'))
        .thenAnswer((_) async => const Err(ServerFailure('hide failed')));
    await provider.hidePost('p1');
    expect(provider.posts, [post1, post2]);
    expect(provider.errorMessage, 'hide failed');

    when(() => hidePost('p1')).thenAnswer((_) async => const Ok(null));
    await provider.hidePost('p1');
    expect(provider.posts, [post2]);

    provider.addPost(post1);
    expect(provider.posts, [post1, post2]);
    provider.updatePost(post1.copyWith(textDetails: 'Edited'));
    expect(provider.getPostById('p1')!.textDetails, 'Edited');
    provider.deletePost('p2');
    expect(provider.posts, hasLength(1));

    provider.reset();
    expect(provider.posts, isEmpty);
    expect(provider.status, ViewStatus.initial);
    expect(provider.hasMore, isTrue);
    expect(provider.isLoadingMore, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('loadMore paginates, deduplicates, stops on short page, and keeps posts on Err',
      () async {
    final pagedProvider = FeedProvider(
      getFeed: getFeed,
      toggleLike: toggleLike,
      addComment: addComment,
      deleteComment: deleteComment,
      toggleCommentLike: toggleCommentLike,
      hidePost: hidePost,
      pageSize: 2,
    );
    final post3 = Post(
      id: 'p3',
      workshopId: 'w1',
      textDetails: 'Post 3',
      createdAt: now,
    );

    when(
      () => getFeed(
        any(
          that: predicate<GetFeedParams>(
            (p) => p.limit == 2 && p.offset == 0,
          ),
        ),
      ),
    ).thenAnswer((_) async => Ok([post1, post2]));
    when(
      () => getFeed(
        any(
          that: predicate<GetFeedParams>(
            (p) => p.limit == 2 && p.offset == 2,
          ),
        ),
      ),
    ).thenAnswer((_) async => Ok([post2, post3]));

    await pagedProvider.load();
    expect(pagedProvider.hasMore, isTrue);

    await pagedProvider.loadMore();
    expect(pagedProvider.posts.map((p) => p.id), ['p1', 'p2', 'p3']);
    expect(pagedProvider.isLoadingMore, isFalse);

    when(
      () => getFeed(
        any(
          that: predicate<GetFeedParams>(
            (p) => p.limit == 2 && p.offset == 4,
          ),
        ),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('page err')));

    await pagedProvider.loadMore();
    expect(pagedProvider.posts.map((p) => p.id), ['p1', 'p2', 'p3']);
    expect(pagedProvider.errorMessage, 'page err');
    expect(pagedProvider.hasMore, isTrue);

    when(
      () => getFeed(
        any(
          that: predicate<GetFeedParams>(
            (p) => p.limit == 2 && p.offset == 4,
          ),
        ),
      ),
    ).thenAnswer((_) async => const Ok([]));

    await pagedProvider.loadMore();
    expect(pagedProvider.hasMore, isFalse);

    await pagedProvider.loadMore();
    verify(() => getFeed(any())).called(4);
  });
}
