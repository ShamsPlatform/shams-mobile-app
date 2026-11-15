/// Fields updated when a user edits their profile.
class ProfileUpdate {
  const ProfileUpdate({
    required this.name,
    required this.username,
    required this.phone,
    required this.bio,
    this.location,
    this.profileImageUrl,
  });

  final String name;
  final String username;
  final String phone;
  final String bio;
  final String? location;
  final String? profileImageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUpdate &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          username == other.username &&
          phone == other.phone &&
          bio == other.bio &&
          location == other.location &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode => Object.hash(
        name,
        username,
        phone,
        bio,
        location,
        profileImageUrl,
      );
}
