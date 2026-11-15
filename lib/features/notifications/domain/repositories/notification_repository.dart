import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';

/// Repository contract for user notifications and realtime notification stream.
abstract interface class NotificationRepository {
  Future<Result<List<AppNotification>>> getNotifications();

  Future<Result<void>> markAsRead(String notificationId);

  Future<Result<void>> markAllAsRead();

  Future<Result<void>> deleteNotification(String notificationId);

  Stream<AppNotification> watchChanges();
}
