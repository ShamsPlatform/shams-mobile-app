import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';

/// Contract for profile operations (minimal scope expanded in Phase 4).
abstract interface class ProfileRepository {
  Future<Result<String>> uploadAvatar({
    required String userId,
    required String localFilePath,
  });

  Future<Result<void>> upsertProfile(ProfileUpsert data);
}
