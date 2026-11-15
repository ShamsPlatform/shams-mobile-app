import 'dart:async';

import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for user notifications and realtime inserts.
abstract interface class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String notificationId);

  Stream<Map<String, dynamic>> watchChanges();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._db);

  final SupabaseClient _db;

  String _requireUserId() {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('لا يوجد مستخدم مسجل دخول');
    }
    return user.id;
  }

  Future<T> _guardDb<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() {
    return _guardDb(() async {
      final userId = _requireUserId();
      return await _db
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
    });
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _guardDb(() async {
      await _db
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    });
  }

  @override
  Future<void> markAllAsRead() {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _guardDb(() async {
      await _db.from('notifications').delete().eq('id', notificationId);
    });
  }

  @override
  Stream<Map<String, dynamic>> watchChanges() {
    final user = _db.auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    late final RealtimeChannel channel;
    final controller = StreamController<Map<String, dynamic>>(
      onCancel: () => _db.removeChannel(channel),
    );

    channel = _db
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(Map<String, dynamic>.from(payload.newRecord));
            }
          },
        )
        .subscribe();

    return controller.stream;
  }
}
