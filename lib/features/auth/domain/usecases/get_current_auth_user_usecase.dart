import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentAuthUserUseCase {
  GetCurrentAuthUserUseCase(this._repository);

  final AuthRepository _repository;

  AuthUser? call() => _repository.currentUser;
}
