import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/features/notifications/data/models/notification_model.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';

void main() {
  test('NotificationModel.fromJson maps full notification payload and types', () {
    final cases = <String, NotificationType>{
      'like': NotificationType.like,
      'comment': NotificationType.comment,
      'reply': NotificationType.reply,
      'workshop_update': NotificationType.workshopUpdate,
      'maintenance_status': NotificationType.maintenanceStatus,
      'message': NotificationType.message,
      'system': NotificationType.system,
      'unexpected_value': NotificationType.system,
    };

    for (final entry in cases.entries) {
      final model = NotificationModel.fromJson({
        'id': 'n1',
        'title': 'عنوان الإشعار',
        'message': 'محتوى الإشعار',
        'created_at': '2026-11-15T08:30:00.000Z',
        'is_read': true,
        'type': entry.key,
        'target_id': 'target-1',
      });

      expect(model.id, 'n1');
      expect(model.title, 'عنوان الإشعار');
      expect(model.message, 'محتوى الإشعار');
      expect(model.createdAt, DateTime.utc(2026, 11, 15, 8, 30));
      expect(model.isRead, true);
      expect(model.type, entry.value);
      expect(model.targetId, 'target-1');
    }
  });

  test('NotificationModel.fromJson applies safe defaults for missing fields', () {
    final model = NotificationModel.fromJson(const {});

    expect(model.id, '');
    expect(model.title, '');
    expect(model.message, '');
    expect(model.isRead, false);
    expect(model.type, NotificationType.system);
    expect(model.targetId, isNull);
  });
}
