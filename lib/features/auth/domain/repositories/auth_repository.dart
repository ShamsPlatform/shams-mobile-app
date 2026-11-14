import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';

/// Contract for authentication and session state operations.
abstract interface class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signInWithGoogle();

  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<void>> signOut();
}
