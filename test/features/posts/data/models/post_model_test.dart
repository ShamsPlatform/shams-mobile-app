import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/features/posts/data/models/comment_model.dart';
import 'package:shams_mobile_app/features/posts/data/models/post_model.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';

void main() {
  group('PostModel.fromJson', () {
    test('maps full Supabase payload with author, workshops ignored cleanly, and comments', () {
      const commentUser = AppUser(id: 'u2', name: 'Sara', email: 'sara@ex.com');
      final comment = Comment(
        id: 'c1',
        postId: 'p1',
        user: commentUser,
        text: 'Nice',
        createdAt: DateTime(2026, 11, 15),
      );

      final post = PostModel.fromJson(
        {
          'id': 'p1',
          'workshop_id': 'w1',
          'text_details': 'Hybrid inverter',
          'images': ['https://cdn.example.com/1.jpg', 'assets/sample.png'],
          'views_count': 45800,
          'created_at': '2026-11-14T12:30:00.000Z',
          'is_highlighted': true,
          'likes_count': 12,
          'profiles': {
            'id': 'u1',
            'name': 'Yusuf',
            'username': 'yusuf',
            'profile_image_url': 'https://cdn.example.com/a.jpg',
            'is_verified': true,
          },
          'workshops': {
            'id': 'w1',
            'name': 'Shams Solar',
            'handle': '@shams',
            'logo_url': null,
          },
        },
        isLiked: true,
        comments: [comment],
      );

      expect(post.id, 'p1');
      expect(post.workshopId, 'w1');
      expect(post.textDetails, 'Hybrid inverter');
      expect(post.images, ['https://cdn.example.com/1.jpg', 'assets/sample.png']);
      expect(post.viewsCount, 45800);
      expect(post.createdAt, DateTime.parse('2026-11-14T12:30:00.000Z').toLocal());
      expect(post.isHighlighted, true);
      expect(post.likesCount, 12);
      expect(post.isLiked, true);
      expect(post.author?.id, 'u1');
      expect(post.author?.name, 'Yusuf');
      expect(post.author?.isVerified, true);
      expect(post.comments, [comment]);
    });

    test('handles missing profiles, missing workshops, and null images/counts', () {
      final post = PostModel.fromJson({
        'id': 'p2',
        'workshop_id': null,
        'text_details': null,
        'images': null,
        'views_count': null,
        'created_at': null,
        'is_highlighted': null,
        'likes_count': null,
        'profiles': null,
      });

      expect(post.id, 'p2');
      expect(post.workshopId, isNull);
      expect(post.textDetails, '');
      expect(post.images, isEmpty);
      expect(post.viewsCount, 0);
      expect(post.isHighlighted, false);
      expect(post.likesCount, 0);
      expect(post.isLiked, false);
      expect(post.author, isNull);
      expect(post.comments, isEmpty);
    });
  });

  group('CommentModel.fromJson', () {
    test('maps full payload and tolerates missing profiles', () {
      final full = CommentModel.fromJson(
        {
          'id': 'c1',
          'post_id': 'p1',
          'text': 'How much?',
          'likes_count': 4,
          'created_at': '2026-11-14T10:00:00.000Z',
          'profiles': {
            'id': 'u2',
            'name': 'Tariq',
            'username': 'tariq',
            'profile_image_url': null,
          },
        },
        isLiked: true,
      );

      expect(full.id, 'c1');
      expect(full.postId, 'p1');
      expect(full.text, 'How much?');
      expect(full.likesCount, 4);
      expect(full.isLiked, true);
      expect(full.user.name, 'Tariq');
      expect(
        full.createdAt,
        DateTime.parse('2026-11-14T10:00:00.000Z').toLocal(),
      );

      final minimal = CommentModel.fromJson({'id': 'c2'});
      expect(minimal.id, 'c2');
      expect(minimal.user.id, '');
      expect(minimal.likesCount, 0);
      expect(minimal.isLiked, false);
    });
  });
}
