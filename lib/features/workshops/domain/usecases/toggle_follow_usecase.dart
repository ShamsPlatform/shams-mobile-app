import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

class ToggleFollowParams {
  const ToggleFollowParams({
    required this.workshopId,
    required this.isCurrentlyFollowing,
  });

  final String workshopId;
  final bool isCurrentlyFollowing;
}

/// Follows or unfollows a workshop based on its current follow state.
class ToggleFollowUseCase implements UseCase<void, ToggleFollowParams> {
  ToggleFollowUseCase(this._repository);

  final WorkshopRepository _repository;

  @override
  Future<Result<void>> call(ToggleFollowParams params) {
    return params.isCurrentlyFollowing
        ? _repository.unfollowWorkshop(params.workshopId)
        : _repository.followWorkshop(params.workshopId);
  }
}
