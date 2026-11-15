import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

class GetMyWorkshopParams {
  const GetMyWorkshopParams({
    this.userId,
    this.fallbackUsername = '',
  });

  final String? userId;
  final String fallbackUsername;
}

/// Loads the signed-in owner's workshop and its follower count.
class GetMyWorkshopUseCase
    implements UseCase<MyWorkshop?, GetMyWorkshopParams> {
  GetMyWorkshopUseCase(this._repository, this._authRepository);

  final WorkshopRepository _repository;
  final AuthRepository _authRepository;

  @override
  Future<Result<MyWorkshop?>> call(GetMyWorkshopParams params) async {
    final requestedId = params.userId;
    final resolvedUserId = (requestedId != null && requestedId.isNotEmpty)
        ? requestedId
        : _authRepository.currentUser?.id;
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      return const Err(AuthFailure('لا يوجد مستخدم مسجل دخول'));
    }
    return _repository.getMyWorkshop(
      userId: resolvedUserId,
      fallbackUsername: params.fallbackUsername,
    );
  }
}
