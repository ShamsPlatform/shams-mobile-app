import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

/// Subscribes to newly inserted notifications for the signed-in user.
class WatchNotificationsUseCase
    implements StreamUseCase<AppNotification, NoParams> {
  WatchNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Stream<AppNotification> call(NoParams params) {
    return _repository.watchChanges();
  }
}
