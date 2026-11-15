import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_update.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileParams {
  const UpdateProfileParams({
    required this.name,
    required this.username,
    required this.phone,
    required this.bio,
    this.location,
    this.newAvatarPath,
  });

  final String name;
  final String username;
  final String phone;
  final String bio;
  final String? location;
  final String? newAvatarPath;
}

/// Uploads a new avatar (fatal on failure), updates the profile row, and returns
/// the refreshed [AppUser].
class UpdateProfileUseCase implements UseCase<AppUser, UpdateProfileParams> {
  UpdateProfileUseCase(this._authRepository, this._profileRepository);

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  @override
  Future<Result<AppUser>> call(UpdateProfileParams params) async {
    final authUser = _authRepository.currentUser;
    if (authUser == null) {
      return const Err(AuthFailure('لا يوجد مستخدم مسجل دخول'));
    }

    String? uploadedImageUrl;
    final avatarPath = params.newAvatarPath;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final uploadResult = await _profileRepository.uploadAvatar(
        userId: authUser.id,
        localFilePath: avatarPath,
      );
      switch (uploadResult) {
        case Ok(:final data):
          uploadedImageUrl = data;
        case Err(:final failure):
          return Err(ServerFailure('فشل رفع الصورة: ${failure.message}'));
      }
    }

    final updateResult = await _profileRepository.updateProfile(
      authUser.id,
      ProfileUpdate(
        name: params.name.trim(),
        username: params.username.trim(),
        phone: params.phone.trim(),
        bio: params.bio.trim(),
        location: params.location,
        profileImageUrl: uploadedImageUrl,
      ),
    );

    if (updateResult case Err(:final failure)) {
      return Err(failure);
    }

    final refetchResult = await _profileRepository.getProfile(authUser.id);
    if (refetchResult case Err(:final failure)) {
      return Err(failure);
    }

    final refetched = (refetchResult as Ok<AppUser?>).data;
    if (refetched != null) {
      final authEmail = authUser.email;
      return Ok(
        authEmail != null && authEmail.isNotEmpty
            ? refetched.copyWith(email: authEmail)
            : refetched,
      );
    }

    return Ok(
      AppUser(
        id: authUser.id,
        name: params.name.trim(),
        email: authUser.email ?? '',
        username: params.username.trim(),
        phone: params.phone.trim(),
        bio: params.bio.trim(),
        location: params.location,
        profileImageUrl: uploadedImageUrl,
      ),
    );
  }
}
