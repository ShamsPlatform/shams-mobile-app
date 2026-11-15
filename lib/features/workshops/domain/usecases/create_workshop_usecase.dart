import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

/// Creates a new workshop for the signed-in user, uploading any local images.
class CreateWorkshopUseCase
    implements UseCase<MyWorkshop, CreateWorkshopParams> {
  CreateWorkshopUseCase(this._repository, this._authRepository);

  final WorkshopRepository _repository;
  final AuthRepository _authRepository;

  @override
  Future<Result<MyWorkshop>> call(CreateWorkshopParams params) async {
    if (_authRepository.currentUser == null) {
      return const Err(AuthFailure('المستخدم غير مسجل الدخول'));
    }
    return _repository.createWorkshop(params);
  }
}
