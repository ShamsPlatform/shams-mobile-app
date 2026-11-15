import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';

/// Input payload for creating a new workshop.
class CreateWorkshopParams {
  const CreateWorkshopParams({
    required this.name,
    required this.city,
    required this.address,
    required this.description,
    required this.handle,
    this.logoPath,
    this.coverPath,
    this.galleryPaths = const [],
    this.services = const [],
    this.yearsOfExperience = 0,
  });

  final String name;
  final String city;
  final String address;
  final String description;
  final String handle;
  final String? logoPath;
  final String? coverPath;
  final List<String> galleryPaths;
  final List<String> services;
  final int yearsOfExperience;
}

/// Input payload for partial updates to an existing workshop.
class UpdateWorkshopParams {
  const UpdateWorkshopParams({
    required this.workshopId,
    this.name,
    this.handle,
    this.city,
    this.description,
    this.yearsOfExperience,
    this.logoUrl,
    this.coverUrl,
    this.galleryUrls,
  });

  final String workshopId;
  final String? name;
  final String? handle;
  final String? city;
  final String? description;
  final int? yearsOfExperience;
  final String? logoUrl;
  final String? coverUrl;
  final List<String>? galleryUrls;

  bool get isEmpty =>
      name == null &&
      handle == null &&
      city == null &&
      description == null &&
      yearsOfExperience == null &&
      logoUrl == null &&
      coverUrl == null &&
      galleryUrls == null;
}

/// Contract for workshop directory, owner dashboard, and follow operations.
abstract interface class WorkshopRepository {
  Future<Result<List<Workshop>>> getPublicWorkshops({
    String? cityFilter,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<MyWorkshop?>> getMyWorkshop({
    required String userId,
    String fallbackUsername = '',
  });

  Future<Result<MyWorkshop>> createWorkshop(CreateWorkshopParams params);

  Future<Result<void>> updateWorkshop(UpdateWorkshopParams params);

  Future<Result<String>> uploadWorkshopImage({
    required String storagePath,
    required String localFilePath,
  });

  Future<Result<void>> followWorkshop(String workshopId);

  Future<Result<void>> unfollowWorkshop(String workshopId);

  // Not used by UI yet.
  Future<Result<Workshop?>> getWorkshopById(String workshopId);

  // Not used by UI yet.
  Future<Result<void>> deleteWorkshop(String workshopId);
}
