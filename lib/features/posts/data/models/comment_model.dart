import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';

/// Maps Supabase comment rows to domain [Comment] entities.
class CommentModel {
  const CommentModel._();

  static Comment fromJson(
    Map<String, dynamic> json, {
    bool isLiked = false,
  }) {
    final rawProfile = json['profiles'];
    final profileMap =
        rawProfile is Map<String, dynamic> ? rawProfile : <String, dynamic>{};

    final rawCreatedAt = json['created_at'];
    final createdAt = rawCreatedAt is String && rawCreatedAt.isNotEmpty
        ? DateTime.parse(rawCreatedAt).toLocal()
        : DateTime.now();

    return Comment(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      user: AppUserModel.fromJson(profileMap),
      text: json['text'] as String? ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: isLiked,
      createdAt: createdAt,
    );
  }
}
