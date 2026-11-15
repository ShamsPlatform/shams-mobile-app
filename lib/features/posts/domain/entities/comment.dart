import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

/// Domain entity representing a comment on a workshop [Post].
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.user,
    required this.text,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final AppUser user;
  final String text;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  Comment copyWith({
    String? id,
    String? postId,
    AppUser? user,
    String? text,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      user: user ?? this.user,
      text: text ?? this.text,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          user == other.user &&
          text == other.text &&
          likesCount == other.likesCount &&
          isLiked == other.isLiked &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, postId, user, text, likesCount, isLiked, createdAt);
}
