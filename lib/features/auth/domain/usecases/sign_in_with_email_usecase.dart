import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailParams {
  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInWithEmailUseCase
    implements UseCase<AuthUser, SignInWithEmailParams> {
  SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(SignInWithEmailParams params) async {
    final email = params.email.trim();
    final password = params.password;

    if (email.isEmpty) {
      return const Err(AuthFailure('يرجى التحقق من البريد الإلكتروني'));
    }
    if (password.isEmpty) {
      return const Err(AuthFailure('كلمة المرور غير صحيحة'));
    }

    return _repository.signInWithEmail(email: email, password: password);
  }
}
