import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/add_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/delete_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_workshop_reviews_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshop_reviews_provider.dart';

class MockGetWorkshopReviewsUseCase extends Mock
    implements GetWorkshopReviewsUseCase {}

class MockAddReviewUseCase extends Mock implements AddReviewUseCase {}

class MockUpdateReviewUseCase extends Mock implements UpdateReviewUseCase {}

class MockDeleteReviewUseCase extends Mock implements DeleteReviewUseCase {}

void main() {
  late MockGetWorkshopReviewsUseCase getWorkshopReviews;
  late MockAddReviewUseCase addReview;
  late MockUpdateReviewUseCase updateReview;
  late MockDeleteReviewUseCase deleteReview;
  late WorkshopReviewsProvider provider;

  final review1 = Review(
    id: 'r1',
    reviewer: const AppUser(id: 'u1', name: 'علي', email: 'a@shams.test'),
    rating: 5.0,
    comment: 'عمل احترافي',
    createdAt: DateTime(2026, 11, 14),
  );
  final review2 = Review(
    id: 'r2',
    reviewer: const AppUser(id: 'u2', name: 'عمر', email: 'o@shams.test'),
    rating: 4.0,
    comment: 'سعر مناسب',
    createdAt: DateTime(2026, 11, 15),
  );

  setUpAll(() {
    registerFallbackValue(
      const AddReviewParams(workshopId: 'w1', rating: 5, comment: 'test'),
    );
    registerFallbackValue(
      const UpdateReviewParams(reviewId: 'r1', rating: 5, comment: 'test'),
    );
  });

  setUp(() {
    getWorkshopReviews = MockGetWorkshopReviewsUseCase();
    addReview = MockAddReviewUseCase();
    updateReview = MockUpdateReviewUseCase();
    deleteReview = MockDeleteReviewUseCase();
    provider = WorkshopReviewsProvider(
      getWorkshopReviews: getWorkshopReviews,
      addReview: addReview,
      updateReview: updateReview,
      deleteReview: deleteReview,
    );
  });

  group('load', () {
    test('populates reviews, computes averageRating, and finds user review',
        () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([review1, review2]));

      await provider.load('w1');

      expect(provider.status, ViewStatus.success);
      expect(provider.reviews, [review1, review2]);
      expect(provider.reviewCount, 2);
      expect(provider.averageRating, 4.5);
      expect(provider.findReviewByUserId('u2')?.id, 'r2');
      expect(provider.findReviewByUserId('u99'), isNull);
    });

    test('sets failure status and errorMessage when load fails', () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => const Err(ServerFailure('load failed')));

      await provider.load('w1', initialReviews: [review1]);

      expect(provider.status, ViewStatus.failure);
      expect(provider.errorMessage, 'load failed');
      expect(provider.reviews, [review1]);
    });
  });

  group('mutations', () {
    test('addReview prepends review and updates average rating', () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([review2]));
      await provider.load('w1');

      when(() => addReview(any())).thenAnswer((_) async => Ok(review1));

      final ok = await provider.addReview(
        workshopId: 'w1',
        rating: 5,
        comment: 'عمل احترافي',
      );

      expect(ok, isTrue);
      expect(provider.isSubmitting, isFalse);
      expect(provider.reviews.first.id, 'r1');
      expect(provider.reviewCount, 2);
      expect(provider.averageRating, 4.5);
    });

    test('addReview exposes errorMessage and returns false on failure',
        () async {
      when(() => addReview(any()))
          .thenAnswer((_) async => const Err(ValidationFailure('invalid')));

      final ok = await provider.addReview(
        workshopId: 'w1',
        rating: 0,
        comment: '',
      );

      expect(ok, isFalse);
      expect(provider.errorMessage, 'invalid');
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });

    test('updateReview edits existing review in place', () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([review1, review2]));
      await provider.load('w1');

      when(() => updateReview(any()))
          .thenAnswer((_) async => const Ok(null));

      final ok = await provider.updateReview(
        reviewId: 'r1',
        rating: 3,
        comment: '  مقبول  ',
      );

      expect(ok, isTrue);
      expect(provider.reviews.first.rating, 3.0);
      expect(provider.reviews.first.comment, 'مقبول');
      expect(provider.reviews.first.reviewer.id, 'u1');
      expect(provider.averageRating, 3.5);
    });

    test('deleteReview removes review and recalculates summary', () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([review1, review2]));
      await provider.load('w1');

      when(() => deleteReview('r1'))
          .thenAnswer((_) async => const Ok(null));

      final ok = await provider.deleteReview('r1');

      expect(ok, isTrue);
      expect(provider.reviews.map((r) => r.id), ['r2']);
      expect(provider.reviewCount, 1);
      expect(provider.averageRating, 4.0);
    });

    test('deleteReview keeps review and sets errorMessage on failure',
        () async {
      when(() => getWorkshopReviews('w1'))
          .thenAnswer((_) async => Ok([review1]));
      await provider.load('w1');

      when(() => deleteReview('r1'))
          .thenAnswer((_) async => const Err(ServerFailure('cannot delete')));

      final ok = await provider.deleteReview('r1');

      expect(ok, isFalse);
      expect(provider.reviews, [review1]);
      expect(provider.errorMessage, 'cannot delete');
    });
  });
}
