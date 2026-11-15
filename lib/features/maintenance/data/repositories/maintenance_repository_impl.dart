import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import 'package:shams_mobile_app/features/maintenance/data/models/maintenance_request_model.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._remote);

  final MaintenanceRemoteDataSource _remote;

  @override
  Future<Result<MaintenanceRequest>> createRequest(
    CreateMaintenanceRequestParams params,
  ) {
    return guard(() async {
      final row = await _remote.createRequest(params);
      return MaintenanceRequestModel.fromJson(row);
    });
  }

  @override
  Future<Result<List<MaintenanceRequest>>> getMyRequests() {
    return guard(() async {
      final rows = await _remote.fetchMyRequests();
      return rows.map(MaintenanceRequestModel.fromJson).toList();
    });
  }

  @override
  Future<Result<List<MaintenanceRequest>>> getWorkshopRequests(
    String workshopId,
  ) {
    return guard(() async {
      final rows = await _remote.fetchWorkshopRequests(workshopId);
      return rows.map(MaintenanceRequestModel.fromJson).toList();
    });
  }

  @override
  Future<Result<void>> updateStatus({
    required String requestId,
    required MaintenanceRequestStatus newStatus,
  }) {
    return guard(
      () => _remote.updateStatus(
        requestId: requestId,
        newStatus: MaintenanceRequestModel.statusToDb(newStatus),
      ),
    );
  }

  @override
  Future<Result<void>> deleteRequest(String requestId) {
    return guard(() => _remote.deleteRequest(requestId));
  }
}
