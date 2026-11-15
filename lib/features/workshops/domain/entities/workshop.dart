import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';

/// Publicly listed workshop visible in the directory and workshop profile.
class Workshop {
  final String id;
  final String ownerId;
  final String name;
  final String handle;
  final String city;
  final double rating;
  final int reviewCount;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> galleryUrls;
  final int yearsOfExperience;
  final bool isFollowing;
  final List<Post> posts;
  final List<String> serviceTypes;
  final String? phone;
  final String? whatsapp;
  final bool isVerified;
  final List<Review> reviews;

  const Workshop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.handle,
    required this.city,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.description = '',
    this.logoUrl,
    this.coverUrl,
    this.galleryUrls = const [],
    this.yearsOfExperience = 0,
    this.isFollowing = false,
    this.posts = const [],
    this.serviceTypes = const [],
    this.phone,
    this.whatsapp,
    this.isVerified = false,
    this.reviews = const [],
  });

  Workshop copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? handle,
    String? city,
    double? rating,
    int? reviewCount,
    String? description,
    String? logoUrl,
    String? coverUrl,
    List<String>? galleryUrls,
    int? yearsOfExperience,
    bool? isFollowing,
    List<Post>? posts,
    List<String>? serviceTypes,
    String? phone,
    String? whatsapp,
    bool? isVerified,
    List<Review>? reviews,
  }) {
    return Workshop(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isFollowing: isFollowing ?? this.isFollowing,
      posts: posts ?? this.posts,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      isVerified: isVerified ?? this.isVerified,
      reviews: reviews ?? this.reviews,
    );
  }
}
