import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_id_by_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/watch_notifications_usecase.dart';

/// App-wide provider managing notifications list, unread badge count,
/// optimistic read/delete updates, and realtime subscription lifecycle.
class NotificationProvider extends ChangeNotifier implements Resettable {
  NotificationProvider({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationAsReadUseCase markNotificationAsRead,
    required MarkAllNotificationsAsReadUseCase markAllNotificationsAsRead,
    required DeleteNotificationUseCase deleteNotification,
    required WatchNotificationsUseCase watchNotifications,
    required GetChatIdByMaintenanceRequestUseCase getChatIdByMaintenanceRequest,
  })  : _getNotifications = getNotifications,
        _markNotificationAsRead = markNotificationAsRead,
        _markAllNotificationsAsRead = markAllNotificationsAsRead,
        _deleteNotification = deleteNotification,
        _watchNotifications = watchNotifications,
        _getChatIdByMaintenanceRequest = getChatIdByMaintenanceRequest;

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationAsReadUseCase _markNotificationAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsRead;
  final DeleteNotificationUseCase _deleteNotification;
  final WatchNotificationsUseCase _watchNotifications;
  final GetChatIdByMaintenanceRequestUseCase _getChatIdByMaintenanceRequest;

  List<AppNotification> _notifications = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  StreamSubscription<AppNotification>? _subscription;
  bool _isDisposed = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  ViewStatus get status => _status;

  String? get errorMessage => _errorMessage;

  /// Loads notifications and activates the realtime insert stream once per session.
  Future<void> load({bool silent = false}) async {
    if (_isDisposed) return;
    if (!silent) {
      _status = ViewStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _getNotifications(const NoParams());
    if (_isDisposed) return;

    result.fold(
      (failure) {
        if (!silent || _notifications.isEmpty) {
          _status = ViewStatus.failure;
        }
        _errorMessage = failure.message;
        notifyListeners();
      },
      (items) {
        _notifications = List<AppNotification>.from(items);
        _status = ViewStatus.success;
        _errorMessage = null;
        _ensureSubscribed();
        notifyListeners();
      },
    );
  }

  void _ensureSubscribed() {
    if (_subscription != null || _isDisposed) return;
    _subscription = _watchNotifications(const NoParams()).listen(
      _onIncomingNotification,
      onError: (Object error) {
        debugPrint('NotificationProvider realtime error: $error');
      },
    );
  }

  void _onIncomingNotification(AppNotification item) {
    if (_isDisposed) return;
    if (item.id.isEmpty) {
      unawaited(load(silent: true));
      return;
    }
    if (_notifications.any((n) => n.id == item.id)) return;
    _notifications.insert(0, item);
    notifyListeners();
  }

  /// Optimistically marks all unread notifications as read, reverting on failure.
  Future<bool> markAllAsRead() async {
    final previous = List<AppNotification>.from(_notifications);
    var changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed && !_isDisposed) {
      notifyListeners();
    }

    final result = await _markAllNotificationsAsRead(const NoParams());
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        if (changed) {
          _notifications = previous;
        }
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _errorMessage = null;
        return true;
      },
    );
  }

  /// Optimistically marks [id] as read, reverting on failure.
  Future<bool> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && _notifications[index].isRead) {
      return true;
    }

    final AppNotification? previous =
        index != -1 ? _notifications[index] : null;
    if (previous != null) {
      _notifications[index] = previous.copyWith(isRead: true);
      if (!_isDisposed) notifyListeners();
    }

    final result = await _markNotificationAsRead(id);
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        if (previous != null && index < _notifications.length) {
          _notifications[index] = previous;
        }
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _errorMessage = null;
        return true;
      },
    );
  }

  /// Optimistically removes [id] immediately (for `Dismissible`) and reverts on error.
  Future<bool> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    final AppNotification? removed =
        index != -1 ? _notifications.removeAt(index) : null;
    if (removed != null && !_isDisposed) {
      notifyListeners();
    }

    final result = await _deleteNotification(id);
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        if (removed != null) {
          final insertAt = index.clamp(0, _notifications.length);
          _notifications.insert(insertAt, removed);
        }
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _errorMessage = null;
        return true;
      },
    );
  }

  /// Resolves the chat thread ID for a maintenance-status notification.
  Future<String?> resolveMaintenanceChatId(String requestId) async {
    final result = await _getChatIdByMaintenanceRequest(requestId);
    if (_isDisposed) return null;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (chatId) {
        _errorMessage = null;
        return chatId;
      },
    );
  }

  @override
  void reset() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _notifications = [];
    _status = ViewStatus.initial;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
