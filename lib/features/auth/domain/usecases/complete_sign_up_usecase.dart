import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
    required this.location,
    this.phone,
    this.bio,
    this.avatarPath,
  });

  final String email;
  final String password;
  final String name;
  final String username;
  final String location;
  final String? phone;
  final String? bio;
  final String? avatarPath;
}

class SignUpOutcome {
  const SignUpOutcome({
    required this.user,
    this.warnings = const [],
  });

  final AuthUser user;
  final List<String> warnings;
}

/// Orchestrates account creation, optional avatar upload, and profile upsert.
///
/// Account creation is fatal; avatar upload and profile upsert produce non-fatal
/// warnings while preserving the created session (per K4 / P2.3).
class CompleteSignUpUseCase implements UseCase<SignUpOutcome, SignUpParams> {
  CompleteSignUpUseCase(this._authRepository, this._profileRepository);

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  @override
  Future<Result<SignUpOutcome>> call(SignUpParams params) async {
    final signUpResult = await _authRepository.signUp(
      email: params.email.trim(),
      password: params.password,
      fullName: params.name.trim(),
    );

    if (signUpResult case Err(:final failure)) {
      return Err(failure);
    }

    final user = (signUpResult as Ok<AuthUser>).data;
    final warnings = <String>[];
    String? profileImageUrl;

    final avatarPath = params.avatarPath;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final uploadResult = await _profileRepository.uploadAvatar(
        userId: user.id,
        localFilePath: avatarPath,
      );
      switch (uploadResult) {
        case Ok(:final data):
          profileImageUrl = data;
        case Err(:final failure):
          warnings.add('حدث خطأ أثناء رفع الصورة: ${failure.message}');
      }
    }

    final upsertResult = await _profileRepository.upsertProfile(
      ProfileUpsert(
        id: user.id,
        name: params.name.trim(),
        username: params.username.trim(),
        location: params.location,
        email: params.email.trim(),
        phone: params.phone?.trim(),
        bio: params.bio?.trim(),
        profileImageUrl: profileImageUrl,
      ),
    );

    if (upsertResult case Err(:final failure)) {
      warnings.add('حدث خطأ أثناء تحديث بيانات الملف: ${failure.message}');
    }

    return Ok(
      SignUpOutcome(
        user: user,
        warnings: List.unmodifiable(warnings),
      ),
    );
  }
}
