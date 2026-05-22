import 'package:flutter/material.dart';

/// Notification type — determines where tapping a notification navigates.
enum NotificationType {
  /// Someone liked the user's post → navigate to post
  like,

  /// Someone commented on the user's post → navigate to post
  comment,

  /// Someone replied to the user's comment → navigate to post
  reply,

  /// A followed workshop published a new post → navigate to workshop profile
  workshopUpdate,

  /// Maintenance request status changed → navigate to chat
  maintenanceStatus,

  /// Generic / system notification
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData? icon;
  final Color? color;

  /// Determines the navigation destination on tap.
  final NotificationType type;

  /// The ID of the target resource (postId, workshopId, chatId, etc.).
  /// May be null for generic system notifications.
  final String? targetId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.icon,
    this.color,
    this.type = NotificationType.system,
    this.targetId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    Color? color,
    NotificationType? type,
    String? targetId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
    );
  }
}
