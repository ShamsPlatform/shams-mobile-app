/// Persisted workshop data for the signed-in owner's dashboard.
class MyWorkshop {
  final String id;
  final String ownerId;
  final String name;
  final String username;
  final String city;
  final String description;
  final int yearsOfExperience;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> galleryUrls;
  final int followersCount;
  final double rating;
  final int reviewCount;

  const MyWorkshop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.username,
    required this.city,
    this.description = '',
    this.yearsOfExperience = 0,
    this.logoUrl,
    this.coverUrl,
    this.galleryUrls = const [],
    this.followersCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  MyWorkshop copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? username,
    String? city,
    String? description,
    int? yearsOfExperience,
    String? logoUrl,
    String? coverUrl,
    List<String>? galleryUrls,
    int? followersCount,
    double? rating,
    int? reviewCount,
  }) {
    return MyWorkshop(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      username: username ?? this.username,
      city: city ?? this.city,
      description: description ?? this.description,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      followersCount: followersCount ?? this.followersCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
