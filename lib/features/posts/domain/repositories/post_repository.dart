import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';

/// Contract for feed, workshop posts, reactions, comments, and post visibility.
abstract interface class PostRepository {
  Future<Result<List<Post>>> fetchFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<List<Post>>> fetchWorkshopPosts({
    required String workshopId,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<Post>> createPost({
    required String workshopId,
    required String textDetails,
    List<String> imagePaths = const [],
    bool isHighlighted = false,
  });

  Future<Result<void>> updatePost({
    required String postId,
    String? textDetails,
    bool? isHighlighted,
  });

  Future<Result<void>> deletePost(String postId);

  Future<Result<void>> hidePost(String postId);

  Future<Result<bool>> toggleLike(String postId);

  Future<Result<Comment>> addComment({
    required String postId,
    required String text,
  });

  Future<Result<void>> deleteComment(String commentId);

  Future<Result<bool>> toggleCommentLike(String commentId);

  // Repository-only methods (not exposed via use cases yet).
  Future<Result<void>> savePost(String postId);

  Future<Result<void>> unsavePost(String postId);
}
