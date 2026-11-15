import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _remote.authStateChanges().distinct((a, b) => a?.id == b?.id);
  }

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guard(
      () => _remote.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Result<void>> signInWithGoogle() {
    return guard(_remote.signInWithGoogle);
  }

  @override
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return guard(
      () => _remote.signUp(
        email: email,
        password: password,
        fullName: fullName,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() {
    return guard(_remote.signOut);
  }
}
