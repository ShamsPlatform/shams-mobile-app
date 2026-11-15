import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_id_by_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkNotificationAsReadUseCase extends Mock
    implements MarkNotificationAsReadUseCase {}

class MockMarkAllNotificationsAsReadUseCase extends Mock
    implements MarkAllNotificationsAsReadUseCase {}

class MockDeleteNotificationUseCase extends Mock
    implements DeleteNotificationUseCase {}

class MockWatchNotificationsUseCase extends Mock
    implements WatchNotificationsUseCase {}

class MockGetChatIdByMaintenanceRequestUseCase extends Mock
    implements GetChatIdByMaintenanceRequestUseCase {}

void main() {
  late MockGetNotificationsUseCase getNotifications;
  late MockMarkNotificationAsReadUseCase markNotificationAsRead;
  late MockMarkAllNotificationsAsReadUseCase markAllNotificationsAsRead;
  late MockDeleteNotificationUseCase deleteNotification;
  late MockWatchNotificationsUseCase watchNotifications;
  late MockGetChatIdByMaintenanceRequestUseCase getChatIdByMaintenanceRequest;
  late StreamController<AppNotification> realtimeController;
  late NotificationProvider provider;

  final now = DateTime.utc(2026, 11, 15, 10, 0);
  final n1 = AppNotification(
    id: 'n1',
    title: 'إعجاب',
    message: 'أعجب بمنشورك',
    createdAt: now,
    isRead: false,
    type: NotificationType.like,
    targetId: 'p1',
  );
  final n2 = AppNotification(
    id: 'n2',
    title: 'رسالة جديدة',
    message: 'مرحباً',
    createdAt: now.add(const Duration(minutes: 1)),
    isRead: true,
    type: NotificationType.message,
    targetId: 'c1',
  );
  final n3Realtime = AppNotification(
    id: 'n3',
    title: 'تحديث صيانة',
    message: 'تم قبول الطلب',
    createdAt: now.add(const Duration(minutes: 2)),
    isRead: false,
    type: NotificationType.maintenanceStatus,
    targetId: 'req-7',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getNotifications = MockGetNotificationsUseCase();
    markNotificationAsRead = MockMarkNotificationAsReadUseCase();
    markAllNotificationsAsRead = MockMarkAllNotificationsAsReadUseCase();
    deleteNotification = MockDeleteNotificationUseCase();
    watchNotifications = MockWatchNotificationsUseCase();
    getChatIdByMaintenanceRequest = MockGetChatIdByMaintenanceRequestUseCase();
    realtimeController = StreamController<AppNotification>.broadcast();

    when(() => watchNotifications(any()))
        .thenAnswer((_) => realtimeController.stream);

    provider = NotificationProvider(
      getNotifications: getNotifications,
      markNotificationAsRead: markNotificationAsRead,
      markAllNotificationsAsRead: markAllNotificationsAsRead,
      deleteNotification: deleteNotification,
      watchNotifications: watchNotifications,
      getChatIdByMaintenanceRequest: getChatIdByMaintenanceRequest,
    );
  });

  tearDown(() async {
    provider.dispose();
    await realtimeController.close();
  });

  test('load populates notifications, computes unreadCount, and subscribes once',
      () async {
    when(() => getNotifications(any()))
        .thenAnswer((_) async => Ok([n1, n2]));

    await provider.load();

    expect(provider.status, ViewStatus.success);
    expect(provider.notifications, [n1, n2]);
    expect(provider.unreadCount, 1);

    await provider.load(silent: true);
    verify(() => watchNotifications(any())).called(1);
  });

  test('realtime insert prepends new unread notification and deduplicates',
      () async {
    when(() => getNotifications(any())).thenAnswer((_) async => Ok([n2]));
    await provider.load();
    expect(provider.unreadCount, 0);

    realtimeController.add(n3Realtime);
    await pumpEventQueue();

    expect(provider.notifications.map((n) => n.id), ['n3', 'n2']);
    expect(provider.unreadCount, 1);

    // Duplicate event is ignored cleanly.
    realtimeController.add(n3Realtime);
    await pumpEventQueue();
    expect(provider.notifications, hasLength(2));
  });

  test('markAsRead updates optimistically and reverts on Err', () async {
    when(() => getNotifications(any())).thenAnswer((_) async => Ok([n1]));
    await provider.load();

    when(() => markNotificationAsRead('n1'))
        .thenAnswer((_) async => const Err(ServerFailure('fail')));

    final ok = await provider.markAsRead('n1');
    expect(ok, false);
    expect(provider.notifications.first.isRead, false);
    expect(provider.unreadCount, 1);
    expect(provider.errorMessage, 'fail');
  });

  test('markAllAsRead updates all unread items optimistically and reverts on Err',
      () async {
    when(() => getNotifications(any()))
        .thenAnswer((_) async => Ok([n1, n3Realtime]));
    await provider.load();
    expect(provider.unreadCount, 2);

    when(() => markAllNotificationsAsRead(any()))
        .thenAnswer((_) async => const Err(NetworkFailure()));

    final ok = await provider.markAllAsRead();
    expect(ok, false);
    expect(provider.unreadCount, 2);
    expect(provider.errorMessage, const NetworkFailure().message);
  });

  test('deleteNotification removes immediately and restores on Err', () async {
    when(() => getNotifications(any())).thenAnswer((_) async => Ok([n1, n2]));
    await provider.load();

    when(() => deleteNotification('n1'))
        .thenAnswer((_) async => const Err(ServerFailure('cannot delete')));

    final ok = await provider.deleteNotification('n1');
    expect(ok, false);
    expect(provider.notifications.map((n) => n.id), ['n1', 'n2']);
    expect(provider.errorMessage, 'cannot delete');
  });

  test('resolveMaintenanceChatId returns chatId on Ok and sets error on Err',
      () async {
    when(() => getChatIdByMaintenanceRequest('req-7'))
        .thenAnswer((_) async => const Ok('chat-99'));
    expect(await provider.resolveMaintenanceChatId('req-7'), 'chat-99');

    when(() => getChatIdByMaintenanceRequest('req-7'))
        .thenAnswer((_) async => const Err(ServerFailure('db down')));
    expect(await provider.resolveMaintenanceChatId('req-7'), isNull);
    expect(provider.errorMessage, 'db down');
  });

  test('reset cancels realtime subscription and clears state', () async {
    when(() => getNotifications(any())).thenAnswer((_) async => Ok([n1]));
    await provider.load();
    expect(realtimeController.hasListener, true);

    provider.reset();

    expect(provider.notifications, isEmpty);
    expect(provider.unreadCount, 0);
    expect(provider.status, ViewStatus.initial);
    expect(provider.errorMessage, isNull);
    await pumpEventQueue();
    expect(realtimeController.hasListener, false);
  });
}
