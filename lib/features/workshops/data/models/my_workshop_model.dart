import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';

/// Maps Supabase workshop rows to owner dashboard [MyWorkshop] entities.
class MyWorkshopModel {
  const MyWorkshopModel._();

  static String? _nonEmptyOrNull(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static MyWorkshop fromJson(
    Map<String, dynamic> json, {
    int followersCount = 0,
    String fallbackUsername = '',
  }) {
    final rawGallery = json['images'];
    final galleryUrls = rawGallery is List
        ? rawGallery.map((e) => e.toString()).toList()
        : const <String>[];

    return MyWorkshop(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: (json['handle'] ?? fallbackUsername)
          .toString()
          .replaceAll('@', ''),
      city: json['city'] as String? ?? '',
      description: json['description'] as String? ?? '',
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      logoUrl: _nonEmptyOrNull(json['logo_url']),
      coverUrl: _nonEmptyOrNull(json['cover_url']),
      galleryUrls: galleryUrls,
      followersCount: followersCount,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
    );
  }
}
