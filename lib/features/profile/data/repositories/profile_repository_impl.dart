import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Result<String>> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) {
    return guard(
      () => _remote.uploadAvatar(
        userId: userId,
        localFilePath: localFilePath,
      ),
    );
  }

  @override
  Future<Result<void>> upsertProfile(ProfileUpsert data) {
    return guard(() => _remote.upsertProfile(data));
  }
}
