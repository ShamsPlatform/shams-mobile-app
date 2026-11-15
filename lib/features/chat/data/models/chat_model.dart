import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/features/chat/data/models/message_model.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';

/// Maps Supabase `chats` JSON rows (with nested participants and messages)
/// to domain [Chat] entities, keeping messages sorted newest-first.
class ChatModel {
  const ChatModel._();

  static Chat fromJson(
    Map<String, dynamic> json, {
    List<Message>? messagesOverride,
  }) {
    final participantsData = json['chat_participants'] as List<dynamic>? ?? [];
    final participants = <AppUser>[];
    for (final entry in participantsData) {
      if (entry is Map<String, dynamic>) {
        final profile = entry['profiles'];
        if (profile is Map<String, dynamic>) {
          participants.add(AppUserModel.fromJson(profile));
        } else {
          participants.add(AppUserModel.fromJson(const {}));
        }
      }
    }

    final messages = messagesOverride ??
        ((json['messages'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MessageModel.fromJson)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

    final lastMsgRaw = json['last_message_at'];
    final lastMessageTime = lastMsgRaw is String
        ? (DateTime.tryParse(lastMsgRaw) ?? DateTime.now())
        : DateTime.now();

    return Chat(
      chatId: json['id'] as String? ?? '',
      participants: participants,
      messages: messages,
      lastMessageTime: lastMessageTime,
      maintenanceRequestId: json['maintenance_req_id'] as String?,
    );
  }
}
