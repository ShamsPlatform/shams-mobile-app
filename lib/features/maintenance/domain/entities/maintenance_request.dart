/// Represents a structured solar maintenance/installation request submitted
/// by a client to a workshop.
class MaintenanceRequest {
  final String id;
  final String workshopId;
  final String clientId;
  final String serviceType;
  final double? systemCapacityKw;
  final String? inverterBrand;
  final String? batteryType;
  final String problemDescription;
  final DateTime requestedAt;
  final MaintenanceRequestStatus status;

  const MaintenanceRequest({
    required this.id,
    required this.workshopId,
    required this.clientId,
    required this.serviceType,
    this.systemCapacityKw,
    this.inverterBrand,
    this.batteryType,
    required this.problemDescription,
    required this.requestedAt,
    this.status = MaintenanceRequestStatus.pending,
  });

  MaintenanceRequest copyWith({
    String? id,
    String? workshopId,
    String? clientId,
    String? serviceType,
    double? systemCapacityKw,
    String? inverterBrand,
    String? batteryType,
    String? problemDescription,
    DateTime? requestedAt,
    MaintenanceRequestStatus? status,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      clientId: clientId ?? this.clientId,
      serviceType: serviceType ?? this.serviceType,
      systemCapacityKw: systemCapacityKw ?? this.systemCapacityKw,
      inverterBrand: inverterBrand ?? this.inverterBrand,
      batteryType: batteryType ?? this.batteryType,
      problemDescription: problemDescription ?? this.problemDescription,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }
}

/// Status lifecycle for a maintenance request.
enum MaintenanceRequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

/// Arabic labels for [MaintenanceRequestStatus].
extension MaintenanceRequestStatusLabel on MaintenanceRequestStatus {
  String get label {
    switch (this) {
      case MaintenanceRequestStatus.pending:
        return 'قيد الانتظار';
      case MaintenanceRequestStatus.accepted:
        return 'مقبول';
      case MaintenanceRequestStatus.inProgress:
        return 'جارٍ التنفيذ';
      case MaintenanceRequestStatus.completed:
        return 'مكتمل';
      case MaintenanceRequestStatus.cancelled:
        return 'ملغي';
    }
  }
}
