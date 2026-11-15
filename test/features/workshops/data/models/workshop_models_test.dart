import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/features/workshops/data/models/my_workshop_model.dart';
import 'package:shams_mobile_app/features/workshops/data/models/review_model.dart';
import 'package:shams_mobile_app/features/workshops/data/models/workshop_model.dart';

void main() {
  group('WorkshopModel.fromJson', () {
    test('maps full Supabase workshop payload accurately', () {
      final workshop = WorkshopModel.fromJson(
        {
          'id': 'w1',
          'owner_id': 'u1',
          'name': 'Shams Solar',
          'handle': '@shams',
          'city': 'صنعاء',
          'rating': 4.7,
          'reviews_count': 15,
          'description': 'Solar installation',
          'logo_url': 'https://cdn.example.com/logo.jpg',
          'cover_url': 'https://cdn.example.com/cover.jpg',
          'images': ['https://cdn.example.com/g1.jpg'],
          'years_of_experience': 8,
          'services': ['تركيب منظومات', 'صيانة'],
          'phone': '777000000',
          'whatsapp': '777111111',
          'is_verified': true,
        },
        isFollowing: true,
      );

      expect(workshop.id, 'w1');
      expect(workshop.ownerId, 'u1');
      expect(workshop.name, 'Shams Solar');
      expect(workshop.handle, '@shams');
      expect(workshop.city, 'صنعاء');
      expect(workshop.rating, 4.7);
      expect(workshop.reviewCount, 15);
      expect(workshop.description, 'Solar installation');
      expect(workshop.logoUrl, 'https://cdn.example.com/logo.jpg');
      expect(workshop.coverUrl, 'https://cdn.example.com/cover.jpg');
      expect(workshop.galleryUrls, ['https://cdn.example.com/g1.jpg']);
      expect(workshop.yearsOfExperience, 8);
      expect(workshop.isFollowing, isTrue);
      expect(workshop.serviceTypes, ['تركيب منظومات', 'صيانة']);
      expect(workshop.phone, '777000000');
      expect(workshop.whatsapp, '777111111');
      expect(workshop.isVerified, isTrue);
    });

    test('maps missing or empty image urls to null instead of fallback assets', () {
      final workshop = WorkshopModel.fromJson({
        'id': 'w2',
        'owner_id': 'u2',
        'name': 'Empty Media',
        'handle': '@empty',
        'city': 'عدن',
        'logo_url': '',
        'cover_url': null,
        'images': null,
        'services': null,
        'rating': null,
        'reviews_count': null,
        'years_of_experience': null,
        'is_verified': null,
      });

      expect(workshop.logoUrl, isNull);
      expect(workshop.coverUrl, isNull);
      expect(workshop.galleryUrls, isEmpty);
      expect(workshop.serviceTypes, isEmpty);
      expect(workshop.rating, 0.0);
      expect(workshop.reviewCount, 0);
      expect(workshop.yearsOfExperience, 0);
      expect(workshop.isVerified, isFalse);
      expect(workshop.isFollowing, isFalse);
    });
  });

  group('MyWorkshopModel.fromJson', () {
    test('maps owner workshop row with followers count and strips @ from handle', () {
      final myWorkshop = MyWorkshopModel.fromJson(
        {
          'id': 'w1',
          'owner_id': 'u1',
          'name': 'My Solar',
          'handle': '@mysolar',
          'city': 'تعز',
          'description': 'Desc',
          'years_of_experience': 5,
          'logo_url': 'https://cdn.example.com/logo.jpg',
          'cover_url': '',
          'images': ['https://cdn.example.com/1.jpg'],
          'rating': 4.5,
          'reviews_count': 3,
        },
        followersCount: 42,
        fallbackUsername: 'fallback',
      );

      expect(myWorkshop.id, 'w1');
      expect(myWorkshop.ownerId, 'u1');
      expect(myWorkshop.username, 'mysolar');
      expect(myWorkshop.logoUrl, 'https://cdn.example.com/logo.jpg');
      expect(myWorkshop.coverUrl, isNull);
      expect(myWorkshop.galleryUrls, ['https://cdn.example.com/1.jpg']);
      expect(myWorkshop.followersCount, 42);
      expect(myWorkshop.rating, 4.5);
      expect(myWorkshop.reviewCount, 3);
    });

    test('uses fallbackUsername when handle is null', () {
      final myWorkshop = MyWorkshopModel.fromJson(
        {'id': 'w1', 'owner_id': 'u1', 'handle': null},
        fallbackUsername: '@owner_handle',
      );

      expect(myWorkshop.username, 'owner_handle');
    });
  });

  group('ReviewModel.fromJson', () {
    test('maps Supabase review row with nested profiles', () {
      final review = ReviewModel.fromJson({
        'id': 'r1',
        'rating': 5,
        'comment': 'خدمة ممتازة',
        'created_at': '2026-11-15T06:00:00.000Z',
        'profiles': {
          'id': 'u9',
          'name': 'خالد',
          'profile_image_url': 'https://cdn.example.com/u9.jpg',
        },
      });

      expect(review.id, 'r1');
      expect(review.rating, 5.0);
      expect(review.comment, 'خدمة ممتازة');
      expect(review.reviewer.id, 'u9');
      expect(review.reviewer.name, 'خالد');
      expect(
        review.createdAt,
        DateTime.parse('2026-11-15T06:00:00.000Z').toLocal(),
      );
    });
  });
}
