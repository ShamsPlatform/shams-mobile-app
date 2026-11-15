import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/watch_notifications_usecase.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repo;

  final sampleNotification = AppNotification(
    id: 'n1',
    title: 'إعجاب جديد',
    message: 'أعجب أحمد بمنشورك',
    createdAt: DateTime.utc(2026, 11, 15, 10, 0),
    type: NotificationType.like,
    targetId: 'post-1',
  );

  setUp(() {
    repo = MockNotificationRepository();
  });

  test('GetNotificationsUseCase returns notification list from repository',
      () async {
    when(() => repo.getNotifications())
        .thenAnswer((_) async => Ok([sampleNotification]));

    final result = await GetNotificationsUseCase(repo)(const NoParams());
    expect(result, isA<Ok<List<AppNotification>>>());
    expect((result as Ok<List<AppNotification>>).data, [sampleNotification]);
  });

  test('MarkNotificationAsReadUseCase delegates id to repository', () async {
    when(() => repo.markAsRead('n1')).thenAnswer((_) async => const Ok(null));

    final result = await MarkNotificationAsReadUseCase(repo)('n1');
    expect(result, isA<Ok<void>>());
    verify(() => repo.markAsRead('n1')).called(1);
  });

  test('MarkAllNotificationsAsReadUseCase delegates markAllAsRead', () async {
    when(() => repo.markAllAsRead())
        .thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await MarkAllNotificationsAsReadUseCase(repo)(
      const NoParams(),
    );
    expect(result, const Err<void>(NetworkFailure()));
    verify(() => repo.markAllAsRead()).called(1);
  });

  test('DeleteNotificationUseCase delegates notificationId', () async {
    when(() => repo.deleteNotification('n1'))
        .thenAnswer((_) async => const Ok(null));

    final result = await DeleteNotificationUseCase(repo)('n1');
    expect(result, isA<Ok<void>>());
    verify(() => repo.deleteNotification('n1')).called(1);
  });

  test('WatchNotificationsUseCase forwards realtime stream', () {
    final controller = StreamController<AppNotification>();
    when(() => repo.watchChanges()).thenAnswer((_) => controller.stream);

    final stream = WatchNotificationsUseCase(repo)(const NoParams());
    expectLater(stream, emitsInOrder([sampleNotification, emitsDone]));

    controller.add(sampleNotification);
    controller.close();
  });
}
