import 'post_model.dart';

/// PublicWorkshopModel — نموذج بيانات الورشة العامة
///
/// Represents a publicly listed workshop visible in [WorkshopsListScreen]
/// and [WorkshopProfile]. Managed by [WorkshopProvider].
class PublicWorkshopModel {
  /// Unique identifier
  final String id;

  /// Display name of the workshop
  final String name;

  /// @handle of the workshop
  final String handle;

  /// City / province
  final String city;

  /// Star rating (0–5)
  final double rating;

  /// Number of reviews
  final int reviewCount;

  /// Short description of the workshop
  final String description;

  /// Asset or network path to the logo
  final String logoPath;

  /// Asset or network path to the cover image
  final String coverImagePath;

  /// Whether the current user follows this workshop
  final bool isFollowing;

  /// Work-log posts displayed on the profile
  final List<PostModel> posts;

  const PublicWorkshopModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.city,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.description = '',
    this.logoPath = 'assets/images/logo/shams logo.png',
    this.coverImagePath = 'assets/images/post image.jpg',
    this.isFollowing = false,
    this.posts = const [],
  });

  PublicWorkshopModel copyWith({
    String? id,
    String? name,
    String? handle,
    String? city,
    double? rating,
    int? reviewCount,
    String? description,
    String? logoPath,
    String? coverImagePath,
    bool? isFollowing,
    List<PostModel>? posts,
  }) {
    return PublicWorkshopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts ?? this.posts,
    );
  }
}
