import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:shams_mobile_app/features/posts/data/models/comment_model.dart';
import 'package:shams_mobile_app/features/posts/data/models/post_model.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._remote);

  final PostRemoteDataSource _remote;

  Future<List<Comment>> _loadCommentsForPost(String postId) async {
    final rows = await _remote.fetchComments(postId);
    return rows.map(CommentModel.fromJson).toList();
  }

  @override
  Future<Result<List<Post>>> fetchFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return guard(() async {
      final rows = await _remote.fetchFeed(
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      if (rows.isEmpty) return const <Post>[];

      final postIds = rows
          .map((p) => p['id'] as String?)
          .whereType<String>()
          .toList();
      final likedIds = postIds.isNotEmpty
          ? await _remote.fetchLikedPostIds(postIds)
          : <String>{};

      final posts = <Post>[];
      for (final item in rows) {
        final id = item['id'] as String? ?? '';
        final comments = await _loadCommentsForPost(id);
        posts.add(
          PostModel.fromJson(
            item,
            isLiked: likedIds.contains(id),
            comments: comments,
          ),
        );
      }
      return posts;
    });
  }

  @override
  Future<Result<List<Post>>> fetchWorkshopPosts({
    required String workshopId,
    int limit = 20,
    int offset = 0,
  }) {
    return guard(() async {
      final rows = await _remote.fetchWorkshopPosts(
        workshopId: workshopId,
        limit: limit,
        offset: offset,
      );

      final posts = <Post>[];
      for (final item in rows) {
        final id = item['id'] as String? ?? '';
        final comments = await _loadCommentsForPost(id);
        posts.add(PostModel.fromJson(item, comments: comments));
      }
      return posts;
    });
  }

  @override
  Future<Result<Post>> createPost({
    required String workshopId,
    required String textDetails,
    List<String> imagePaths = const [],
    bool isHighlighted = false,
  }) {
    return guard(() async {
      final row = await _remote.createPost(
        workshopId: workshopId,
        textDetails: textDetails,
        imagePaths: imagePaths,
        isHighlighted: isHighlighted,
      );
      return PostModel.fromJson(row);
    });
  }

  @override
  Future<Result<void>> updatePost({
    required String postId,
    String? textDetails,
    bool? isHighlighted,
  }) {
    return guard(
      () => _remote.updatePost(
        postId: postId,
        textDetails: textDetails,
        isHighlighted: isHighlighted,
      ),
    );
  }

  @override
  Future<Result<void>> deletePost(String postId) {
    return guard(() => _remote.deletePost(postId));
  }

  @override
  Future<Result<void>> hidePost(String postId) {
    return guard(() => _remote.hidePost(postId));
  }

  @override
  Future<Result<bool>> toggleLike(String postId) {
    return guard(() => _remote.toggleLike(postId));
  }

  @override
  Future<Result<Comment>> addComment({
    required String postId,
    required String text,
  }) {
    return guard(() async {
      final row = await _remote.addComment(postId: postId, text: text);
      return CommentModel.fromJson(row);
    });
  }

  @override
  Future<Result<void>> deleteComment(String commentId) {
    return guard(() => _remote.deleteComment(commentId));
  }

  @override
  Future<Result<bool>> toggleCommentLike(String commentId) {
    return guard(() => _remote.toggleCommentLike(commentId));
  }

  @override
  Future<Result<void>> savePost(String postId) {
    return guard(() => _remote.savePost(postId));
  }

  @override
  Future<Result<void>> unsavePost(String postId) {
    return guard(() => _remote.unsavePost(postId));
  }
}
