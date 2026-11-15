import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';

/// Deletes a user-authored workshop review by ID.
class DeleteReviewUseCase implements UseCase<void, String> {
  DeleteReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<void>> call(String reviewId) async {
    if (reviewId.trim().isEmpty) {
      return const Err(ValidationFailure('معرّف التقييم غير صالح'));
    }
    return _repository.deleteReview(reviewId);
  }
}
