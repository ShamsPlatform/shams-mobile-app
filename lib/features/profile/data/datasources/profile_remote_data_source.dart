import 'dart:io';

import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRemoteDataSource {
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  });

  Future<void> upsertProfile(ProfileUpsert data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(
    this._client,
    this._storage, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _avatarsBucket = 'avatars';

  final SupabaseClient _client;
  final FileStorageDataSource _storage;
  final DateTime Function() _clock;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  }) async {
    try {
      final bytes = await File(localFilePath).readAsBytes();
      final parts = localFilePath.split('.');
      final fileExt = parts.length > 1 ? parts.last : 'jpg';
      final fileName = '$userId-${_clock().millisecondsSinceEpoch}.$fileExt';
      return await _storage.uploadBytes(
        bucket: _avatarsBucket,
        path: fileName,
        bytes: bytes,
      );
    } on ServerException {
      rethrow;
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } on FileSystemException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> upsertProfile(ProfileUpsert data) async {
    final updates = <String, dynamic>{
      'id': data.id,
      'name': data.name,
      'username': data.username,
      'location': data.location,
      'email': data.email,
    };

    final phone = data.phone;
    if (phone != null && phone.isNotEmpty) {
      updates['phone'] = phone;
    }
    final bio = data.bio;
    if (bio != null && bio.isNotEmpty) {
      updates['bio'] = bio;
    }
    final imageUrl = data.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      updates['profile_image_url'] = imageUrl;
    }

    try {
      await _client.from('profiles').upsert(updates);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
