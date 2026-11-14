import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

void main() {
  group('AppUserModel', () {
    test('fromJson maps full payload accurately', () {
      final json = <String, dynamic>{
        'id': 'user-1',
        'name': 'أحمد محمد',
        'email': 'ahmed@example.com',
        'profile_image_url': 'https://cdn.example.com/avatar.png',
        'bio': 'مهندس طاقة شمسية',
        'phone': '+967770000000',
        'username': 'ahmed_solar',
        'location': 'صنعاء',
        'is_verified': true,
        'has_workshop': true,
      };

      final user = AppUserModel.fromJson(json);

      expect(
        user,
        const AppUser(
          id: 'user-1',
          name: 'أحمد محمد',
          email: 'ahmed@example.com',
          profileImageUrl: 'https://cdn.example.com/avatar.png',
          bio: 'مهندس طاقة شمسية',
          phone: '+967770000000',
          username: 'ahmed_solar',
          location: 'صنعاء',
          isVerified: true,
          hasWorkshop: true,
        ),
      );
    });

    test('fromJson applies defaults for missing and null fields', () {
      final json = <String, dynamic>{
        'id': null,
        'name': null,
        'email': 'a@b.com',
        'profile_image_url': null,
        'is_verified': null,
      };

      final user = AppUserModel.fromJson(json);

      expect(user.id, '');
      expect(user.name, '');
      expect(user.email, 'a@b.com');
      expect(user.profileImageUrl, isNull);
      expect(user.bio, isNull);
      expect(user.phone, isNull);
      expect(user.username, isNull);
      expect(user.location, isNull);
      expect(user.isVerified, isFalse);
      expect(user.hasWorkshop, isFalse);
    });

    test('fromJson handles empty map', () {
      final user = AppUserModel.fromJson(const {});

      expect(
        user,
        const AppUser(id: '', name: '', email: ''),
      );
    });

    test('toJson serializes all fields for round-trip mapping', () {
      const user = AppUser(
        id: 'u-2',
        name: 'سارة',
        email: 'sara@example.com',
        profileImageUrl: 'https://example.com/p.jpg',
        bio: 'bio',
        phone: '12345',
        username: 'sara',
        location: 'عدن',
        isVerified: true,
        hasWorkshop: false,
      );

      final json = AppUserModel.toJson(user);

      expect(AppUserModel.fromJson(json), user);
    });
  });
}
