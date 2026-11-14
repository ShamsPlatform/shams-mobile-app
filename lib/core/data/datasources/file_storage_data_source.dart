import 'dart:io';
import 'dart:typed_data';

import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FileStorageDataSource {
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required String localFilePath,
  });

  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  });

  // Not used by UI yet.
  Future<void> delete({required String bucket, required String path});
}

class FileStorageDataSourceImpl implements FileStorageDataSource {
  final SupabaseClient _client;

  const FileStorageDataSourceImpl(this._client);

  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required String localFilePath,
  }) async {
    try {
      final storage = _client.storage.from(bucket);
      await storage.upload(
        path,
        File(localFilePath),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return storage.getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {
    try {
      final storage = _client.storage.from(bucket);
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return storage.getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> delete({required String bucket, required String path}) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    }
  }
}
