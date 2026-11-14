/// Payload for creating or updating the initial user profile during sign-up.
class ProfileUpsert {
  const ProfileUpsert({
    required this.id,
    required this.name,
    required this.username,
    required this.location,
    required this.email,
    this.phone,
    this.bio,
    this.profileImageUrl,
  });

  final String id;
  final String name;
  final String username;
  final String location;
  final String email;
  final String? phone;
  final String? bio;
  final String? profileImageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUpsert &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          location == other.location &&
          email == other.email &&
          phone == other.phone &&
          bio == other.bio &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        username,
        location,
        email,
        phone,
        bio,
        profileImageUrl,
      );
}
