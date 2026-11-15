import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';

/// Parameters for creating a new solar maintenance request.
class CreateMaintenanceRequestParams {
  final String workshopId;
  final String serviceType;
  final String problemDescription;
  final double? systemCapacityKw;
  final String? inverterBrand;
  final String? batteryType;

  const CreateMaintenanceRequestParams({
    required this.workshopId,
    required this.serviceType,
    required this.problemDescription,
    this.systemCapacityKw,
    this.inverterBrand,
    this.batteryType,
  });
}

/// Repository contract for managing maintenance requests.
abstract interface class MaintenanceRepository {
  Future<Result<MaintenanceRequest>> createRequest(
    CreateMaintenanceRequestParams params,
  );

  // Not used by UI yet.
  Future<Result<List<MaintenanceRequest>>> getMyRequests();

  // Not used by UI yet.
  Future<Result<List<MaintenanceRequest>>> getWorkshopRequests(
    String workshopId,
  );

  // Not used by UI yet.
  Future<Result<void>> updateStatus({
    required String requestId,
    required MaintenanceRequestStatus newStatus,
  });

  // Not used by UI yet.
  Future<Result<void>> deleteRequest(String requestId);
}
