import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/review_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/repositories/review_repository_impl.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';

class MockReviewRemoteDataSource extends Mock
    implements ReviewRemoteDataSource {}

void main() {
  late MockReviewRemoteDataSource remote;
  late ReviewRepositoryImpl repository;

  setUp(() {
    remote = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(remote);
  });

  group('ReviewRepositoryImpl', () {
    test('addReview and getWorkshopReviews map rows to Review entities', () async {
      when(
        () => remote.addReview(
          workshopId: 'w1',
          rating: 4.5,
          comment: 'Very good',
        ),
      ).thenAnswer(
        (_) async => {
          'id': 'r1',
          'rating': 4.5,
          'comment': 'Very good',
          'created_at': '2026-11-15T00:00:00.000Z',
          'profiles': {'id': 'u1', 'name': 'Omar'},
        },
      );
      when(() => remote.fetchWorkshopReviews('w1')).thenAnswer(
        (_) async => [
          {
            'id': 'r1',
            'rating': 4.5,
            'comment': 'Very good',
            'created_at': '2026-11-15T00:00:00.000Z',
            'profiles': {'id': 'u1', 'name': 'Omar'},
          },
        ],
      );

      final added = await repository.addReview(
        workshopId: 'w1',
        rating: 4.5,
        comment: 'Very good',
      );
      expect((added as Ok<Review>).data.id, 'r1');

      final list = await repository.getWorkshopReviews('w1');
      expect((list as Ok<List<Review>>).data.single.reviewer.name, 'Omar');
    });

    test('updateReview and deleteReview wrap exceptions in Failure', () async {
      when(
        () => remote.updateReview(reviewId: 'r1', rating: 5, comment: 'Top'),
      ).thenAnswer((_) async {});
      when(() => remote.deleteReview('r1'))
          .thenThrow(const ServerException('delete failed'));

      expect(
        await repository.updateReview(reviewId: 'r1', rating: 5, comment: 'Top'),
        isA<Ok<void>>(),
      );
      final err = await repository.deleteReview('r1');
      expect((err as Err<void>).failure, const ServerFailure('delete failed'));
    });
  });
}
