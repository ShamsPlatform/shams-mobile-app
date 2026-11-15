import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/add_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/delete_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_workshop_reviews_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_review_usecase.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository repository;
  late GetWorkshopReviewsUseCase getWorkshopReviews;
  late AddReviewUseCase addReview;
  late UpdateReviewUseCase updateReview;
  late DeleteReviewUseCase deleteReview;

  final sampleReview = Review(
    id: 'r1',
    reviewer: const AppUser(id: 'u1', name: 'سالم', email: 's@shams.test'),
    rating: 5.0,
    comment: 'خدمة ممتازة',
    createdAt: DateTime(2026, 11, 15),
  );

  setUp(() {
    repository = MockReviewRepository();
    getWorkshopReviews = GetWorkshopReviewsUseCase(repository);
    addReview = AddReviewUseCase(repository);
    updateReview = UpdateReviewUseCase(repository);
    deleteReview = DeleteReviewUseCase(repository);
  });

  group('GetWorkshopReviewsUseCase', () {
    test('rejects blank workshopId with ValidationFailure', () async {
      final result = await getWorkshopReviews('   ');

      expect(result, isA<Err<List<Review>>>());
      expect((result as Err<List<Review>>).failure, isA<ValidationFailure>());
      verifyNever(() => repository.getWorkshopReviews(any()));
    });

    test('delegates valid workshopId to repository', () async {
      when(() => repository.getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([sampleReview]));

      final result = await getWorkshopReviews('w1');

      expect((result as Ok<List<Review>>).data, [sampleReview]);
      verify(() => repository.getWorkshopReviews('w1')).called(1);
    });
  });

  group('AddReviewUseCase', () {
    test('validates workshopId, rating range, and non-empty comment', () async {
      final emptyWorkshop = await addReview(
        const AddReviewParams(workshopId: ' ', rating: 5, comment: 'ممتاز'),
      );
      expect((emptyWorkshop as Err<Review>).failure, isA<ValidationFailure>());

      final lowRating = await addReview(
        const AddReviewParams(workshopId: 'w1', rating: 0, comment: 'ممتاز'),
      );
      expect((lowRating as Err<Review>).failure, isA<ValidationFailure>());

      final highRating = await addReview(
        const AddReviewParams(workshopId: 'w1', rating: 6, comment: 'ممتاز'),
      );
      expect((highRating as Err<Review>).failure, isA<ValidationFailure>());

      final emptyComment = await addReview(
        const AddReviewParams(workshopId: 'w1', rating: 4, comment: '   '),
      );
      expect((emptyComment as Err<Review>).failure, isA<ValidationFailure>());

      verifyNever(
        () => repository.addReview(
          workshopId: any(named: 'workshopId'),
          rating: any(named: 'rating'),
          comment: any(named: 'comment'),
        ),
      );
    });

    test('trims comment and forwards to repository', () async {
      when(
        () => repository.addReview(
          workshopId: 'w1',
          rating: 5,
          comment: 'خدمة ممتازة',
        ),
      ).thenAnswer((_) async => Ok(sampleReview));

      final result = await addReview(
        const AddReviewParams(
          workshopId: 'w1',
          rating: 5,
          comment: '  خدمة ممتازة  ',
        ),
      );

      expect((result as Ok<Review>).data, sampleReview);
      verify(
        () => repository.addReview(
          workshopId: 'w1',
          rating: 5,
          comment: 'خدمة ممتازة',
        ),
      ).called(1);
    });
  });

  group('UpdateReviewUseCase', () {
    test('validates reviewId, presence of changes, rating, and comment',
        () async {
      final blankId = await updateReview(
        const UpdateReviewParams(reviewId: '', rating: 4),
      );
      expect((blankId as Err<void>).failure, isA<ValidationFailure>());

      final noChanges = await updateReview(
        const UpdateReviewParams(reviewId: 'r1'),
      );
      expect((noChanges as Err<void>).failure, isA<ValidationFailure>());

      final badRating = await updateReview(
        const UpdateReviewParams(reviewId: 'r1', rating: 5.5),
      );
      expect((badRating as Err<void>).failure, isA<ValidationFailure>());

      final blankComment = await updateReview(
        const UpdateReviewParams(reviewId: 'r1', comment: '   '),
      );
      expect((blankComment as Err<void>).failure, isA<ValidationFailure>());

      verifyNever(
        () => repository.updateReview(
          reviewId: any(named: 'reviewId'),
          rating: any(named: 'rating'),
          comment: any(named: 'comment'),
        ),
      );
    });

    test('trims comment and forwards valid updates', () async {
      when(
        () => repository.updateReview(
          reviewId: 'r1',
          rating: 4,
          comment: 'جيد جداً',
        ),
      ).thenAnswer((_) async => const Ok(null));

      final result = await updateReview(
        const UpdateReviewParams(
          reviewId: 'r1',
          rating: 4,
          comment: '  جيد جداً ',
        ),
      );

      expect(result, isA<Ok<void>>());
      verify(
        () => repository.updateReview(
          reviewId: 'r1',
          rating: 4,
          comment: 'جيد جداً',
        ),
      ).called(1);
    });
  });

  group('DeleteReviewUseCase', () {
    test('rejects empty reviewId', () async {
      final result = await deleteReview(' ');

      expect((result as Err<void>).failure, isA<ValidationFailure>());
      verifyNever(() => repository.deleteReview(any()));
    });

    test('delegates valid reviewId', () async {
      when(() => repository.deleteReview('r1'))
          .thenAnswer((_) async => const Ok(null));

      final result = await deleteReview('r1');

      expect(result, isA<Ok<void>>());
      verify(() => repository.deleteReview('r1')).called(1);
    });
  });
}
