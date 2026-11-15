import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';

/// Fetches all user reviews submitted for a workshop.
class GetWorkshopReviewsUseCase implements UseCase<List<Review>, String> {
  GetWorkshopReviewsUseCase(this._repository);

  final ReviewRepository _repository;

  @override
  Future<Result<List<Review>>> call(String workshopId) async {
    if (workshopId.trim().isEmpty) {
      return const Err(ValidationFailure('معرّف الورشة غير صالح'));
    }
    return _repository.getWorkshopReviews(workshopId);
  }
}
