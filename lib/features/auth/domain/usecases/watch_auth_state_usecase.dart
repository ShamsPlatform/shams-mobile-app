import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase implements StreamUseCase<AuthUser?, NoParams> {
  WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AuthUser?> call(NoParams params) {
    return _repository.authStateChanges();
  }
}
