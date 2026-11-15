import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:shams_mobile_app/features/chat/data/models/chat_model.dart';
import 'package:shams_mobile_app/features/chat/data/models/message_model.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  Future<Result<List<Chat>>> getChats() {
    return guard(() async {
      final rows = await _remote.fetchChats();
      return rows.map(ChatModel.fromJson).toList();
    });
  }

  @override
  Future<Result<Chat?>> getChatById(String chatId) {
    return guard(() async {
      final row = await _remote.fetchChatById(chatId);
      if (row == null) return null;
      return ChatModel.fromJson(row);
    });
  }

  @override
  Future<Result<String?>> getChatIdByMaintenanceRequest(String requestId) {
    return guard(() => _remote.fetchChatIdByMaintenanceRequest(requestId));
  }

  @override
  Future<Result<String>> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  }) {
    return guard(
      () => _remote.getOrCreateChat(
        otherUserId: otherUserId,
        maintenanceRequestId: maintenanceRequestId,
      ),
    );
  }

  @override
  Future<Result<List<Message>>> getMessages(
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) {
    return guard(() async {
      final rows = await _remote.fetchMessages(
        chatId: chatId,
        limit: limit,
        offset: offset,
      );
      return rows.map(MessageModel.fromJson).toList();
    });
  }

  @override
  Future<Result<Message>> sendMessage({
    required String chatId,
    required String text,
  }) {
    return guard(() async {
      final row = await _remote.sendMessage(chatId: chatId, text: text);
      return MessageModel.fromJson(row);
    });
  }

  @override
  Future<Result<void>> markChatAsRead(String chatId) {
    return guard(() => _remote.markChatAsRead(chatId));
  }

  @override
  Future<Result<void>> deleteChats(List<String> chatIds) {
    return guard(() => _remote.deleteChats(chatIds));
  }

  @override
  Stream<Message> watchNewMessages(String chatId) {
    return _remote.watchNewMessages(chatId).map(MessageModel.fromJson);
  }

  @override
  Stream<void> watchChatListChanges(List<String> chatIds) {
    return _remote.watchChatListChanges(chatIds);
  }
}
