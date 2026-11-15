import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/review_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/models/review_model.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';

/// Not used by UI yet.
class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  @override
  Future<Result<Review>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  }) {
    return guard(() async {
      final row = await _remote.addReview(
        workshopId: workshopId,
        rating: rating,
        comment: comment,
      );
      return ReviewModel.fromJson(row);
    });
  }

  @override
  Future<Result<List<Review>>> getWorkshopReviews(String workshopId) {
    return guard(() async {
      final rows = await _remote.fetchWorkshopReviews(workshopId);
      return rows.map(ReviewModel.fromJson).toList();
    });
  }

  @override
  Future<Result<void>> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) {
    return guard(
      () => _remote.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      ),
    );
  }

  @override
  Future<Result<void>> deleteReview(String reviewId) {
    return guard(() => _remote.deleteReview(reviewId));
  }
}
