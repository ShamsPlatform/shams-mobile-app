import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

/// Maps Supabase `profiles` JSON payloads to and from [AppUser].
class AppUserModel {
  const AppUserModel._();

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      location: json['location'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      hasWorkshop: json['has_workshop'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'profile_image_url': user.profileImageUrl,
      'bio': user.bio,
      'phone': user.phone,
      'username': user.username,
      'location': user.location,
      'is_verified': user.isVerified,
      'has_workshop': user.hasWorkshop,
    };
  }
}
