import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/default_profile.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

/// Loads the signed-in user's profile, auto-creating a default row when missing
/// (for instance after a fresh OAuth sign-in).
class GetMyProfileUseCase implements UseCase<AppUser, NoParams> {
  GetMyProfileUseCase(this._authRepository, this._profileRepository);

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  @override
  Future<Result<AppUser>> call(NoParams params) async {
    final authUser = _authRepository.currentUser;
    if (authUser == null) {
      return const Err(AuthFailure('لا يوجد مستخدم مسجل دخول'));
    }

    final initialResult = await _profileRepository.getProfile(authUser.id);
    if (initialResult case Err(:final failure)) {
      return Err(failure);
    }

    var profile = (initialResult as Ok<AppUser?>).data;

    if (profile == null) {
      final defaultPayload = _buildDefaultProfile(authUser);
      final createResult =
          await _profileRepository.createDefaultProfile(defaultPayload);
      if (createResult case Err(:final failure)) {
        return Err(failure);
      }

      final refetchResult = await _profileRepository.getProfile(authUser.id);
      if (refetchResult case Err(:final failure)) {
        return Err(failure);
      }
      profile = (refetchResult as Ok<AppUser?>).data;
      if (profile == null) {
        return const Err(NotFoundFailure('تعذر تحميل بيانات الملف الشخصي'));
      }
    }

    final authEmail = authUser.email;
    if (authEmail != null && authEmail.isNotEmpty) {
      profile = profile.copyWith(email: authEmail);
    }

    return Ok(profile);
  }

  DefaultProfile _buildDefaultProfile(AuthUser authUser) {
    final email = authUser.email ?? '';
    final idPrefix = authUser.id.length >= 5
        ? authUser.id.substring(0, 5)
        : authUser.id;
    final defaultUsername = email.isNotEmpty
        ? email.split('@').first
        : 'user_$idPrefix';
    final displayName = authUser.displayName;
    final defaultName =
        (displayName != null && displayName.isNotEmpty)
            ? displayName
            : 'مستخدم شمس';

    return DefaultProfile(
      id: authUser.id,
      name: defaultName,
      username: defaultUsername,
      email: email,
      hasWorkshop: false,
    );
  }
}
