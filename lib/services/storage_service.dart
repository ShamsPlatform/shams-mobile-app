import 'dart:io';

import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/di/injection.dart';

/// Temporary shim delegating to [FileStorageDataSource] until legacy screens
/// and services are migrated (deleted in Phase 5).
class StorageService {
  /// Uploads [file] to [bucket]/[path] and returns the public URL.
  static Future<String> uploadImage({
    required String bucket,
    required String path,
    required File file,
  }) {
    return sl<FileStorageDataSource>().uploadFile(
      bucket: bucket,
      path: path,
      localFilePath: file.path,
    );
  }

  /// Deletes a file from storage.
  static Future<void> deleteImage({
    required String bucket,
    required String path,
  }) {
    return sl<FileStorageDataSource>().delete(bucket: bucket, path: path);
  }
}
