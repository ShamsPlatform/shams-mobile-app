import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

class GetPublicWorkshopsParams {
  const GetPublicWorkshopsParams({
    this.cityFilter,
    this.limit = 20,
    this.offset = 0,
  });

  final String? cityFilter;
  final int limit;
  final int offset;
}

/// Fetches the public directory of workshops with follow status.
class GetPublicWorkshopsUseCase
    implements UseCase<List<Workshop>, GetPublicWorkshopsParams> {
  GetPublicWorkshopsUseCase(this._repository);

  final WorkshopRepository _repository;

  @override
  Future<Result<List<Workshop>>> call(GetPublicWorkshopsParams params) {
    return _repository.getPublicWorkshops(
      cityFilter: params.cityFilter,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
