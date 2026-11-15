import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';

class AddReviewParams {
  const AddReviewParams({
    required this.workshopId,
    required this.rating,
    required this.comment,
  });

  final String workshopId;
  final double rating;
  final String comment;
}

/// Validates and submits a new workshop review.
class AddReviewUseCase implements UseCase<Review, AddReviewParams> {
  AddReviewUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<Review>> call(AddReviewParams params) async {
    if (params.workshopId.trim().isEmpty) {
      return const Err(ValidationFailure('معرّف الورشة غير صالح'));
    }
    if (params.rating < 1.0 || params.rating > 5.0) {
      return const Err(
        ValidationFailure('يرجى اختيار تقييم من 1 إلى 5 نجوم'),
      );
    }
    final trimmedComment = params.comment.trim();
    if (trimmedComment.isEmpty) {
      return const Err(
        ValidationFailure('يرجى كتابة تعليق عن تجربتك مع الورشة'),
      );
    }
    return _repository.addReview(
      workshopId: params.workshopId,
      rating: params.rating,
      comment: trimmedComment,
    );
  }
}
