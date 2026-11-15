import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';

/// Maps Supabase `messages` JSON rows to domain [Message] entities.
class MessageModel {
  const MessageModel._();

  static Message fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final timestamp = createdAtRaw is String
        ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
        : DateTime.now();

    return Message(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: timestamp,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
