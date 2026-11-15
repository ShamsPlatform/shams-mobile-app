/// Initial profile payload auto-created when an authenticated user has no row yet.
class DefaultProfile {
  const DefaultProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.hasWorkshop = false,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final bool hasWorkshop;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          email == other.email &&
          hasWorkshop == other.hasWorkshop;

  @override
  int get hashCode => Object.hash(id, name, username, email, hasWorkshop);
}
