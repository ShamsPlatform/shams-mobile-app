import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';

class UpdateReviewParams {
  const UpdateReviewParams({
    required this.reviewId,
    this.rating,
    this.comment,
  });

  final String reviewId;
  final double? rating;
  final String? comment;
}

/// Validates and updates an existing workshop review.
class UpdateReviewUseCase implements UseCase<void, UpdateReviewParams> {
  UpdateReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<void>> call(UpdateReviewParams params) async {
    if (params.reviewId.trim().isEmpty) {
      return const Err(ValidationFailure('معرّف التقييم غير صالح'));
    }
    if (params.rating == null && params.comment == null) {
      return const Err(
        ValidationFailure('لا توجد تعديلات لحفظها'),
      );
    }
    if (params.rating != null &&
        (params.rating! < 1.0 || params.rating! > 5.0)) {
      return const Err(
        ValidationFailure('يرجى اختيار تقييم من 1 إلى 5 نجوم'),
      );
    }
    final trimmedComment = params.comment?.trim();
    if (trimmedComment != null && trimmedComment.isEmpty) {
      return const Err(
        ValidationFailure('يرجى كتابة تعليق عن تجربتك مع الورشة'),
      );
    }
    return _repository.updateReview(
      reviewId: params.reviewId,
      rating: params.rating,
      comment: trimmedComment,
    );
  }
}
