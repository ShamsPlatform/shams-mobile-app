import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/default_profile.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_update.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';

/// Contract for profile operations.
abstract interface class ProfileRepository {
  Future<Result<String>> uploadAvatar({
    required String userId,
    required String localFilePath,
  });

  Future<Result<void>> upsertProfile(ProfileUpsert data);

  Future<Result<AppUser?>> getProfile(String userId);

  Future<Result<void>> createDefaultProfile(DefaultProfile data);

  Future<Result<void>> updateProfile(String userId, ProfileUpdate data);
}
