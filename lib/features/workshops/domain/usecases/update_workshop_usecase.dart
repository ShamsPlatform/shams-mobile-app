import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

/// Applies partial updates to an existing workshop.
class UpdateWorkshopUseCase implements UseCase<void, UpdateWorkshopParams> {
  UpdateWorkshopUseCase(this._repository);

  final WorkshopRepository _repository;

  @override
  Future<Result<void>> call(UpdateWorkshopParams params) {
    if (params.isEmpty) {
      return Future.value(const Ok<void>(null));
    }
    return _repository.updateWorkshop(params);
  }
}
