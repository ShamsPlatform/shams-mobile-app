import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:shams_mobile_app/features/notifications/data/models/notification_model.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> getNotifications() {
    return guard(() async {
      final rows = await _remote.fetchNotifications();
      return rows.map(NotificationModel.fromJson).toList();
    });
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) {
    return guard(() => _remote.markAsRead(notificationId));
  }

  @override
  Future<Result<void>> markAllAsRead() {
    return guard(() => _remote.markAllAsRead());
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) {
    return guard(() => _remote.deleteNotification(notificationId));
  }

  @override
  Stream<AppNotification> watchChanges() {
    return _remote.watchChanges().map(NotificationModel.fromJson);
  }
}
