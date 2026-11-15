import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';

/// Marks all unread notifications for the current user as read.
class MarkAllNotificationsAsReadUseCase implements UseCase<void, NoParams> {
  MarkAllNotificationsAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.markAllAsRead();
  }
}
