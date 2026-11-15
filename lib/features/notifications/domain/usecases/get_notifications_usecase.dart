import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

/// Fetches the current user's recent notifications (newest first).
class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<List<AppNotification>>> call(NoParams params) {
    return _repository.getNotifications();
  }
}
