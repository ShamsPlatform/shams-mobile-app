import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';

/// Contract for workshop review operations.
abstract interface class ReviewRepository {
  Future<Result<Review>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  });

  Future<Result<List<Review>>> getWorkshopReviews(String workshopId);

  Future<Result<void>> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  });

  Future<Result<void>> deleteReview(String reviewId);
}
