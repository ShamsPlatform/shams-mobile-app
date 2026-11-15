import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:shams_mobile_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

void main() {
  late MockNotificationRemoteDataSource remote;
  late NotificationRepositoryImpl repo;

  setUp(() {
    remote = MockNotificationRemoteDataSource();
    repo = NotificationRepositoryImpl(remote);
  });

  test('getNotifications maps rows to AppNotification entities', () async {
    when(() => remote.fetchNotifications()).thenAnswer(
      (_) async => [
        {
          'id': 'n1',
          'title': 'رسالة جديدة',
          'message': 'مرحباً بك',
          'created_at': '2026-11-15T09:00:00.000Z',
          'is_read': false,
          'type': 'message',
          'target_id': 'c1',
        },
      ],
    );

    final result = await repo.getNotifications();
    expect(result, isA<Ok<List<AppNotification>>>());
    final items = (result as Ok<List<AppNotification>>).data;
    expect(items, hasLength(1));
    expect(items.first.type, NotificationType.message);
    expect(items.first.targetId, 'c1');
  });

  test('getNotifications maps ServerException to ServerFailure', () async {
    when(() => remote.fetchNotifications())
        .thenThrow(const ServerException('db error'));

    final result = await repo.getNotifications();
    expect(result, const Err<List<AppNotification>>(ServerFailure('db error')));
  });

  test('markAsRead, markAllAsRead, and deleteNotification delegate via guard',
      () async {
    when(() => remote.markAsRead('n1')).thenAnswer((_) async {});
    when(() => remote.markAllAsRead()).thenAnswer((_) async {});
    when(() => remote.deleteNotification('n1')).thenAnswer((_) async {});

    expect(await repo.markAsRead('n1'), isA<Ok<void>>());
    expect(await repo.markAllAsRead(), isA<Ok<void>>());
    expect(await repo.deleteNotification('n1'), isA<Ok<void>>());

    verify(() => remote.markAsRead('n1')).called(1);
    verify(() => remote.markAllAsRead()).called(1);
    verify(() => remote.deleteNotification('n1')).called(1);
  });

  test('watchChanges maps incoming JSON rows to AppNotification stream', () {
    final controller = StreamController<Map<String, dynamic>>();
    when(() => remote.watchChanges()).thenAnswer((_) => controller.stream);

    final stream = repo.watchChanges();
    expectLater(
      stream,
      emitsInOrder([
        isA<AppNotification>()
            .having((n) => n.id, 'id', 'n2')
            .having((n) => n.type, 'type', NotificationType.maintenanceStatus),
        emitsDone,
      ]),
    );

    controller.add({
      'id': 'n2',
      'title': 'تحديث صيانة',
      'message': 'قيد التنفيذ',
      'created_at': '2026-11-15T10:00:00.000Z',
      'is_read': false,
      'type': 'maintenance_status',
      'target_id': 'req-9',
    });
    controller.close();
  });
}
