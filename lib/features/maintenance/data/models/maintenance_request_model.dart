import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';

/// Maps Supabase `maintenance_requests` JSON rows to domain [MaintenanceRequest]
/// entities and converts statuses back to DB representations.
class MaintenanceRequestModel {
  const MaintenanceRequestModel._();

  static MaintenanceRequest fromJson(Map<String, dynamic> json) {
    var dbStatus = json['status'] as String? ?? '';
    if (dbStatus == 'in_progress') {
      dbStatus = 'inProgress';
    }

    final requestedRaw = json['requested_at'];
    final requestedAt = requestedRaw is String
        ? (DateTime.tryParse(requestedRaw) ?? DateTime.now())
        : DateTime.now();

    return MaintenanceRequest(
      id: json['id'] as String? ?? '',
      workshopId: json['workshop_id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      systemCapacityKw: (json['system_capacity_kw'] as num?)?.toDouble(),
      inverterBrand: json['inverter_brand'] as String?,
      batteryType: json['battery_type'] as String?,
      problemDescription: json['problem_description'] as String? ?? '',
      requestedAt: requestedAt,
      status: MaintenanceRequestStatus.values.firstWhere(
        (e) => e.name == dbStatus,
        orElse: () => MaintenanceRequestStatus.pending,
      ),
    );
  }

  static String statusToDb(MaintenanceRequestStatus status) {
    return status == MaintenanceRequestStatus.inProgress
        ? 'in_progress'
        : status.name;
  }
}
