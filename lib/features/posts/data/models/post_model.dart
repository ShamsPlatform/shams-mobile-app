import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';

/// Maps Supabase post rows to domain [Post] entities.
class PostModel {
  const PostModel._();

  static Post fromJson(
    Map<String, dynamic> json, {
    bool isLiked = false,
    List<Comment> comments = const [],
  }) {
    final rawAuthor = json['profiles'];
    final author = rawAuthor is Map<String, dynamic>
        ? AppUserModel.fromJson(rawAuthor)
        : null;

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : const <String>[];

    final rawCreatedAt = json['created_at'];
    final createdAt = rawCreatedAt is String && rawCreatedAt.isNotEmpty
        ? DateTime.parse(rawCreatedAt).toLocal()
        : DateTime.now();

    return Post(
      id: json['id'] as String? ?? '',
      workshopId: json['workshop_id'] as String?,
      textDetails: json['text_details'] as String? ?? '',
      images: images,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      author: author,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: isLiked,
      comments: comments,
    );
  }
}
