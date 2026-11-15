import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';

/// Domain entity representing a workshop post in the feed or dashboard.
class Post {
  const Post({
    required this.id,
    this.workshopId,
    required this.textDetails,
    this.images = const [],
    this.viewsCount = 0,
    required this.createdAt,
    this.isHighlighted = false,
    this.author,
    this.likesCount = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  final String id;
  final String? workshopId;
  final String textDetails;
  final List<String> images;
  final int viewsCount;
  final DateTime createdAt;
  final bool isHighlighted;
  final AppUser? author;
  final int likesCount;
  final bool isLiked;
  final List<Comment> comments;

  Post copyWith({
    String? id,
    String? workshopId,
    String? textDetails,
    List<String>? images,
    int? viewsCount,
    DateTime? createdAt,
    bool? isHighlighted,
    AppUser? author,
    int? likesCount,
    bool? isLiked,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      textDetails: textDetails ?? this.textDetails,
      images: images ?? this.images,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          workshopId == other.workshopId &&
          textDetails == other.textDetails &&
          _listEquals(images, other.images) &&
          viewsCount == other.viewsCount &&
          createdAt == other.createdAt &&
          isHighlighted == other.isHighlighted &&
          author == other.author &&
          likesCount == other.likesCount &&
          isLiked == other.isLiked &&
          _listEquals(comments, other.comments);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        workshopId,
        textDetails,
        Object.hashAll(images),
        viewsCount,
        createdAt,
        isHighlighted,
        author,
        likesCount,
        isLiked,
        Object.hashAll(comments),
      );
}
