import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'قام أحمد خالد بالإعجاب بمنشورك',
      message: 'أحمد خالد أبدى إعجابه بمنشورك',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.favorite_rounded,
      color: ShamsColors.dangerRed,
      type: NotificationType.like,
      targetId: 'p1',
    ),
    NotificationModel(
      id: '2',
      title: 'ورشة المجد أضافت عرضاً جديداً في منظومات الطاقة',
      message: 'تصفح العرض الجديد الآن',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      icon: Icons.local_offer_rounded,
      color: ShamsColors.verifiedGreen,
      type: NotificationType.workshopUpdate,
      targetId: 'w1',
    ),
    NotificationModel(
      id: '3',
      title: 'رد جديد على تعليقك من محمد النور',
      message: 'محمد النور رد على تعليقك في المنشور',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.reply_rounded,
      color: ShamsColors.primaryBlue,
      type: NotificationType.reply,
      targetId: 'p2',
    ),
    NotificationModel(
      id: '4',
      title: 'تم قبول طلب الصيانة الخاص بك',
      message: 'ورشة رواد الطاقة البديلة قبلت طلبك. تابع المحادثة.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      icon: Icons.build_circle_rounded,
      color: ShamsColors.solarYellow,
      type: NotificationType.maintenanceStatus,
      targetId: null,
    ),
  ];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }
}
