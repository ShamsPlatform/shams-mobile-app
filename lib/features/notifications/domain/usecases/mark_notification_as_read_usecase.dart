import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

/// Marks a single notification as read.
class MarkNotificationAsReadUseCase implements UseCase<void, String> {
  MarkNotificationAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
