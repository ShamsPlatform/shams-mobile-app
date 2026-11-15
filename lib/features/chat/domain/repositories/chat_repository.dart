import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';

/// Repository contract for chat conversations, messages, and realtime streams.
abstract interface class ChatRepository {
  Future<Result<List<Chat>>> getChats();

  Future<Result<Chat?>> getChatById(String chatId);

  // Used when opening a chat directly from a maintenance-status notification.
  Future<Result<String?>> getChatIdByMaintenanceRequest(String requestId);

  Future<Result<String>> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  });

  Future<Result<Message>> sendMessage({
    required String chatId,
    required String text,
  });

  Future<Result<void>> markChatAsRead(String chatId);

  Future<Result<void>> deleteChats(List<String> chatIds);

  Stream<Message> watchNewMessages(String chatId);

  Stream<void> watchChatListChanges(List<String> chatIds);

  // Supports paginated message loading for a single conversation.
  Future<Result<List<Message>>> getMessages(
    String chatId, {
    int limit = 50,
    int offset = 0,
  });
}
