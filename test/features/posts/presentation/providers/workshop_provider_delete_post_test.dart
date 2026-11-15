import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:shams_mobile_app/providers/workshop_provider.dart';

class MockDeletePostUseCase extends Mock implements DeletePostUseCase {}

void main() {
  late MockDeletePostUseCase deletePost;
  late WorkshopProvider provider;

  final now = DateTime(2026, 11, 15, 4, 0);
  final post1 = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Post 1',
    createdAt: now,
  );
  final post2 = Post(
    id: 'p2',
    workshopId: 'w1',
    textDetails: 'Post 2',
    createdAt: now,
  );

  setUp(() {
    deletePost = MockDeletePostUseCase();
    provider = WorkshopProvider(deletePost: deletePost);
    provider.addPost(post2);
    provider.addPost(post1);
  });

  group('WorkshopProvider.deletePost (B1)', () {
    test('removes post and returns true when DeletePostUseCase succeeds', () async {
      when(() => deletePost('p1')).thenAnswer((_) async => const Ok<void>(null));

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final deleted = await provider.deletePost('p1');

      expect(deleted, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.posts.map((p) => p.id), ['p2']);
      expect(notifyCount, 1);
      verify(() => deletePost('p1')).called(1);
    });

    test('keeps post, sets errorMessage, and returns false on Err', () async {
      when(() => deletePost('p1')).thenAnswer(
        (_) async => const Err<void>(ServerFailure('فشل الاتصال بالخادم')),
      );

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final deleted = await provider.deletePost('p1');

      expect(deleted, isFalse);
      expect(provider.errorMessage, 'فشل الاتصال بالخادم');
      expect(provider.posts.map((p) => p.id), ['p1', 'p2']);
      expect(notifyCount, 1);
      verify(() => deletePost('p1')).called(1);
    });
  });
}
