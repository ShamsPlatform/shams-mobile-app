import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:shams_mobile_app/features/posts/data/repositories/post_repository_impl.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

void main() {
  late MockPostRemoteDataSource remote;
  late PostRepositoryImpl repository;

  setUp(() {
    remote = MockPostRemoteDataSource();
    repository = PostRepositoryImpl(remote);
  });

  group('fetchFeed', () {
    test('returns empty list immediately when remote feed is empty', () async {
      when(
        () => remote.fetchFeed(currentUserId: 'u1', limit: 20, offset: 0),
      ).thenAnswer((_) async => []);

      final result = await repository.fetchFeed(currentUserId: 'u1');

      expect(result, isA<Ok<List<Post>>>());
      expect((result as Ok<List<Post>>).data, isEmpty);
      verifyNever(() => remote.fetchLikedPostIds(any()));
      verifyNever(() => remote.fetchComments(any()));
    });

    test('merges liked post ids and per-post comments', () async {
      when(
        () => remote.fetchFeed(currentUserId: 'u1', limit: 20, offset: 0),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'p1',
            'workshop_id': 'w1',
            'text_details': 'First',
            'created_at': '2026-11-15T00:00:00.000Z',
          },
          {
            'id': 'p2',
            'workshop_id': 'w1',
            'text_details': 'Second',
            'created_at': '2026-11-15T01:00:00.000Z',
          },
        ],
      );
      when(() => remote.fetchLikedPostIds(['p1', 'p2']))
          .thenAnswer((_) async => {'p2'});
      when(() => remote.fetchComments('p1')).thenAnswer(
        (_) async => [
          {
            'id': 'c1',
            'post_id': 'p1',
            'text': 'Hello',
            'created_at': '2026-11-15T00:10:00.000Z',
            'profiles': {'id': 'u2', 'name': 'Noor'},
          },
        ],
      );
      when(() => remote.fetchComments('p2')).thenAnswer((_) async => []);

      final result = await repository.fetchFeed(currentUserId: 'u1');

      expect(result, isA<Ok<List<Post>>>());
      final posts = (result as Ok<List<Post>>).data;
      expect(posts, hasLength(2));
      expect(posts[0].isLiked, false);
      expect(posts[0].comments.single.text, 'Hello');
      expect(posts[1].isLiked, true);
      expect(posts[1].comments, isEmpty);
    });

    test('maps ServerException to ServerFailure', () async {
      when(
        () => remote.fetchFeed(currentUserId: 'u1', limit: 20, offset: 0),
      ).thenThrow(const ServerException('db fail'));

      final result = await repository.fetchFeed(currentUserId: 'u1');

      expect(
        result,
        equals(const Err<List<Post>>(ServerFailure('db fail'))),
      );
    });
  });

  group('fetchWorkshopPosts', () {
    test('maps rows and attaches comments', () async {
      when(
        () => remote.fetchWorkshopPosts(workshopId: 'w1', limit: 20, offset: 0),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'p1',
            'workshop_id': 'w1',
            'text_details': 'Workshop post',
            'created_at': '2026-11-15T00:00:00.000Z',
          },
        ],
      );
      when(() => remote.fetchComments('p1')).thenAnswer((_) async => []);

      final result = await repository.fetchWorkshopPosts(workshopId: 'w1');

      expect(result, isA<Ok<List<Post>>>());
      expect((result as Ok<List<Post>>).data.single.id, 'p1');
    });
  });

  group('mutations and failure mapping', () {
    test('createPost and addComment map returned rows', () async {
      when(
        () => remote.createPost(
          workshopId: 'w1',
          textDetails: 'New',
          imagePaths: const ['/a.jpg'],
          isHighlighted: true,
        ),
      ).thenAnswer(
        (_) async => {
          'id': 'p9',
          'workshop_id': 'w1',
          'text_details': 'New',
          'images': ['https://cdn/a.jpg'],
          'created_at': '2026-11-15T02:00:00.000Z',
          'is_highlighted': true,
        },
      );
      when(() => remote.addComment(postId: 'p9', text: 'First!'))
          .thenAnswer(
        (_) async => {
          'id': 'c9',
          'post_id': 'p9',
          'text': 'First!',
          'created_at': '2026-11-15T02:05:00.000Z',
        },
      );

      final created = await repository.createPost(
        workshopId: 'w1',
        textDetails: 'New',
        imagePaths: const ['/a.jpg'],
        isHighlighted: true,
      );
      expect(created, isA<Ok<Post>>());
      expect((created as Ok<Post>).data.images, ['https://cdn/a.jpg']);

      final added = await repository.addComment(postId: 'p9', text: 'First!');
      expect(added, isA<Ok<Comment>>());
      expect((added as Ok<Comment>).data.text, 'First!');
    });

    test('wraps AppAuthException as AuthFailure across mutations', () async {
      when(() => remote.toggleLike('p1'))
          .thenThrow(const AppAuthException('not signed in'));
      when(() => remote.deletePost('p1'))
          .thenThrow(const ServerException('cannot delete'));
      when(() => remote.hidePost('p1')).thenAnswer((_) async {});
      when(
        () => remote.updatePost(
          postId: 'p1',
          textDetails: 'Edited',
          isHighlighted: false,
        ),
      ).thenAnswer((_) async {});
      when(() => remote.deleteComment('c1')).thenAnswer((_) async {});
      when(() => remote.toggleCommentLike('c1')).thenAnswer((_) async => true);
      when(() => remote.savePost('p1')).thenAnswer((_) async {});
      when(() => remote.unsavePost('p1')).thenAnswer((_) async {});

      expect(
        await repository.toggleLike('p1'),
        equals(const Err<bool>(AuthFailure('not signed in'))),
      );
      expect(
        await repository.deletePost('p1'),
        equals(const Err<void>(ServerFailure('cannot delete'))),
      );
      expect(await repository.hidePost('p1'), isA<Ok<void>>());
      expect(
        await repository.updatePost(
          postId: 'p1',
          textDetails: 'Edited',
          isHighlighted: false,
        ),
        isA<Ok<void>>(),
      );
      expect(await repository.deleteComment('c1'), isA<Ok<void>>());
      expect(await repository.toggleCommentLike('c1'), equals(const Ok(true)));
      expect(await repository.savePost('p1'), isA<Ok<void>>());
      expect(await repository.unsavePost('p1'), isA<Ok<void>>());
    });
  });
}
