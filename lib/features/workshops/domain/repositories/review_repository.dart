import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';

/// Contract for workshop review operations.
///
/// Not used by UI yet.
abstract interface class ReviewRepository {
  // Not used by UI yet.
  Future<Result<Review>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  });

  // Not used by UI yet.
  Future<Result<List<Review>>> getWorkshopReviews(String workshopId);

  // Not used by UI yet.
  Future<Result<void>> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  });

  // Not used by UI yet.
  Future<Result<void>> deleteReview(String reviewId);
}
