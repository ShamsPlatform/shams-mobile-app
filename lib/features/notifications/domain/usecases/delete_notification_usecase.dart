import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

/// Permanently deletes a notification by its identifier.
class DeleteNotificationUseCase implements UseCase<void, String> {
  DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }
}
