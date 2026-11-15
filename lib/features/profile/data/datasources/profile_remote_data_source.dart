import 'dart:io';

import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/default_profile.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_update.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRemoteDataSource {
  Future<String> uploadAvatar({
    required String userId,
    required String localFilePath,
  });

  Future<void> upsertProfile(ProfileUpsert data);

  Future<AppUser?> getProfile(String userId);

  Future<void> createDefaultProfile(DefaultProfile data);

  Future<void> updateProfile(String userId, ProfileUpdate data);
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

  @override
  Future<AppUser?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return AppUserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> createDefaultProfile(DefaultProfile data) async {
    try {
      await _client.from('profiles').upsert({
        'id': data.id,
        'name': data.name,
        'username': data.username,
        'email': data.email,
        'has_workshop': data.hasWorkshop,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> updateProfile(String userId, ProfileUpdate data) async {
    final updates = <String, dynamic>{
      'name': data.name,
      'username': data.username,
      'phone': data.phone,
      'bio': data.bio,
      'location': data.location,
    };
    if (data.profileImageUrl != null) {
      updates['profile_image_url'] = data.profileImageUrl;
    }

    try {
      await _client.from('profiles').update(updates).eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
