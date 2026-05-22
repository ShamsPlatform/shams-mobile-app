class UserModel {
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

  const UserModel({
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

  UserModel copyWith({
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
    return UserModel(
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'phone': phone,
      'username': username,
      'location': location,
      'is_verified': isVerified,
      'has_workshop': hasWorkshop,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profile_image_url'],
      bio: map['bio'],
      phone: map['phone'],
      username: map['username'],
      location: map['location'],
      isVerified: map['is_verified'] ?? false,
      hasWorkshop: map['has_workshop'] ?? false,
    );
  }
}
