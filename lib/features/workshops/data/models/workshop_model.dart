import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';

/// Maps Supabase workshop rows to domain [Workshop] entities.
class WorkshopModel {
  const WorkshopModel._();

  static String? _nonEmptyOrNull(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static Workshop fromJson(
    Map<String, dynamic> json, {
    bool isFollowing = false,
    List<Post> posts = const [],
    List<Review> reviews = const [],
  }) {
    final rawGallery = json['images'];
    final galleryUrls = rawGallery is List
        ? rawGallery.map((e) => e.toString()).toList()
        : const <String>[];

    final rawServices = json['services'];
    final serviceTypes = rawServices is List
        ? rawServices.map((e) => e.toString()).toList()
        : const <String>[];

    return Workshop(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      city: json['city'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      logoUrl: _nonEmptyOrNull(json['logo_url']),
      coverUrl: _nonEmptyOrNull(json['cover_url']),
      galleryUrls: galleryUrls,
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      isFollowing: isFollowing,
      posts: posts,
      serviceTypes: serviceTypes,
      phone: _nonEmptyOrNull(json['phone']),
      whatsapp: _nonEmptyOrNull(json['whatsapp']),
      isVerified: json['is_verified'] as bool? ?? false,
      reviews: reviews,
    );
  }
}
