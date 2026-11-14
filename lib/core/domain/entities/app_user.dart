/// Shared domain user entity used across auth, profile, posts, workshops, and chat.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? phone;
  final String? username;
  final String? location;
  final bool isVerified;
  final bool hasWorkshop;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.phone,
    this.username,
    this.location,
    this.isVerified = false,
    this.hasWorkshop = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? phone,
    String? username,
    String? location,
    bool? isVerified,
    bool? hasWorkshop,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      hasWorkshop: hasWorkshop ?? this.hasWorkshop,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.profileImageUrl == profileImageUrl &&
          other.bio == bio &&
          other.phone == phone &&
          other.username == username &&
          other.location == location &&
          other.isVerified == isVerified &&
          other.hasWorkshop == hasWorkshop;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        profileImageUrl,
        bio,
        phone,
        username,
        location,
        isVerified,
        hasWorkshop,
      );
}
