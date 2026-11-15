import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

enum WorkshopImageKind { logo, cover, gallery }

class UploadWorkshopImageParams {
  const UploadWorkshopImageParams({
    required this.ownerId,
    required this.kind,
    required this.localFilePath,
  });

  final String ownerId;
  final WorkshopImageKind kind;
  final String localFilePath;
}

/// Uploads a logo, cover, or gallery image to the workshops storage bucket.
class UploadWorkshopImageUseCase
    implements UseCase<String, UploadWorkshopImageParams> {
  UploadWorkshopImageUseCase(
    this._repository, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final WorkshopRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<Result<String>> call(UploadWorkshopImageParams params) {
    final timestamp = _clock().millisecondsSinceEpoch;
    final prefix = switch (params.kind) {
      WorkshopImageKind.logo => 'logo_edit',
      WorkshopImageKind.cover => 'cover_edit',
      WorkshopImageKind.gallery => 'gallery',
    };
    final storagePath = '${params.ownerId}/${prefix}_$timestamp.jpg';
    return _repository.uploadWorkshopImage(
      storagePath: storagePath,
      localFilePath: params.localFilePath,
    );
  }
}
