import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/features/maintenance/data/models/maintenance_request_model.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';

void main() {
  group('MaintenanceRequestModel', () {
    test('fromJson maps snake_case payload and in_progress status', () {
      final request = MaintenanceRequestModel.fromJson({
        'id': 'req-1',
        'workshop_id': 'w1',
        'client_id': 'u1',
        'service_type': 'صيانة عاكس',
        'system_capacity_kw': 8,
        'inverter_brand': 'Deye',
        'battery_type': 'ليثيوم',
        'problem_description': 'انخفاض الجهد',
        'requested_at': '2026-11-15T09:30:00.000Z',
        'status': 'in_progress',
      });

      expect(request.id, 'req-1');
      expect(request.workshopId, 'w1');
      expect(request.clientId, 'u1');
      expect(request.serviceType, 'صيانة عاكس');
      expect(request.systemCapacityKw, 8.0);
      expect(request.inverterBrand, 'Deye');
      expect(request.batteryType, 'ليثيوم');
      expect(request.problemDescription, 'انخفاض الجهد');
      expect(request.requestedAt, DateTime.utc(2026, 11, 15, 9, 30));
      expect(request.status, MaintenanceRequestStatus.inProgress);
    });

    test('statusToDb encodes inProgress as in_progress', () {
      expect(
        MaintenanceRequestModel.statusToDb(MaintenanceRequestStatus.inProgress),
        'in_progress',
      );
      expect(
        MaintenanceRequestModel.statusToDb(MaintenanceRequestStatus.completed),
        'completed',
      );
    });
  });
}
