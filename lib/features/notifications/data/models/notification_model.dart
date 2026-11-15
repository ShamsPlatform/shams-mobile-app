import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';

/// Data model mapping Supabase `notifications` rows to [AppNotification].
class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    super.isRead,
    super.type,
    super.targetId,
  });

  static const Map<String, NotificationType> _typeMap = {
    'like': NotificationType.like,
    'comment': NotificationType.comment,
    'reply': NotificationType.reply,
    'workshop_update': NotificationType.workshopUpdate,
    'maintenance_status': NotificationType.maintenanceStatus,
    'message': NotificationType.message,
    'system': NotificationType.system,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> map) {
    final rawCreatedAt = map['created_at']?.toString();
    final createdAt = rawCreatedAt != null
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return NotificationModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      createdAt: createdAt,
      isRead: (map['is_read'] as bool?) ?? false,
      type: parseType(map['type'] as String?),
      targetId: map['target_id'] as String?,
    );
  }

  static NotificationType parseType(String? rawType) {
    return _typeMap[rawType] ?? NotificationType.system;
  }
}
