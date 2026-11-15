import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';

/// Represents a 1-to-1 chat thread with its participants and recent messages.
class Chat {
  final String chatId;
  final List<AppUser> participants;
  final List<Message> messages;
  final DateTime lastMessageTime;
  final String? maintenanceRequestId;

  const Chat({
    required this.chatId,
    this.participants = const [],
    this.messages = const [],
    required this.lastMessageTime,
    this.maintenanceRequestId,
  });

  Chat copyWith({
    String? chatId,
    List<AppUser>? participants,
    List<Message>? messages,
    DateTime? lastMessageTime,
    String? maintenanceRequestId,
  }) {
    return Chat(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      maintenanceRequestId: maintenanceRequestId ?? this.maintenanceRequestId,
    );
  }
}
