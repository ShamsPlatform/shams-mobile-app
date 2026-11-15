/// Notification type — determines where tapping a notification navigates.
enum NotificationType {
  /// Someone liked the user's post → navigate to post.
  like,

  /// Someone commented on the user's post → navigate to post.
  comment,

  /// Someone replied to the user's comment → navigate to post.
  reply,

  /// A followed workshop published a new post → navigate to workshop profile.
  workshopUpdate,

  /// Maintenance request status changed → navigate to chat.
  maintenanceStatus,

  /// New message received → navigate to chat.
  message,

  /// Generic / system notification.
  system,
}

/// Pure domain entity representing an in-app user notification.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  /// ID of the navigation target (postId, workshopId, chatId, or requestId).
  final String? targetId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.system,
    this.targetId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
    String? targetId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppNotification &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            title == other.title &&
            message == other.message &&
            createdAt == other.createdAt &&
            isRead == other.isRead &&
            type == other.type &&
            targetId == other.targetId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        message,
        createdAt,
        isRead,
        type,
        targetId,
      );
}
