import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/delete_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_chat_list_changes_usecase.dart';

/// App-wide provider for the signed-in user's inbox list and chat-list
/// realtime subscription.
class ChatListProvider extends ChangeNotifier implements Resettable {
  ChatListProvider({
    required GetChatsUseCase getChats,
    required MarkChatAsReadUseCase markChatAsRead,
    required GetOrCreateChatUseCase getOrCreateChat,
    required DeleteChatsUseCase deleteChats,
    required WatchChatListChangesUseCase watchChatListChanges,
  })  : _getChats = getChats,
        _markChatAsRead = markChatAsRead,
        _getOrCreateChat = getOrCreateChat,
        _deleteChats = deleteChats,
        _watchChatListChanges = watchChatListChanges;

  final GetChatsUseCase _getChats;
  final MarkChatAsReadUseCase _markChatAsRead;
  final GetOrCreateChatUseCase _getOrCreateChat;
  final DeleteChatsUseCase _deleteChats;
  final WatchChatListChangesUseCase _watchChatListChanges;

  List<Chat> _chats = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  StreamSubscription<void>? _listSubscription;
  List<String> _subscribedChatIds = const [];
  bool _isDisposed = false;

  List<Chat> get chats => List.unmodifiable(_chats);
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Chat? getChatById(String chatId) {
    for (final chat in _chats) {
      if (chat.chatId == chatId) return chat;
    }
    return null;
  }

  /// Fetches all chats and ensures the realtime list subscription matches the
  /// current chat IDs. When [silent] is true (e.g., background realtime reload),
  /// existing UI stays visible without entering [ViewStatus.loading].
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _status = ViewStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _getChats(const NoParams());
    if (_isDisposed) return;

    await result.fold(
      (failure) async {
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (chats) async {
        _chats = List<Chat>.from(chats);
        _status = ViewStatus.success;
        _errorMessage = null;
        await _syncSubscription();
        if (!_isDisposed) notifyListeners();
      },
    );
  }

  Future<void> _syncSubscription() async {
    final chatIds = _chats.map((c) => c.chatId).toList(growable: false);
    if (_listEquals(chatIds, _subscribedChatIds) &&
        (_listSubscription != null || chatIds.isEmpty)) {
      return;
    }

    await _listSubscription?.cancel();
    _listSubscription = null;
    _subscribedChatIds = chatIds;

    if (chatIds.isEmpty || _isDisposed) return;

    _listSubscription = _watchChatListChanges(chatIds).listen(
      (_) {
        if (!_isDisposed) {
          unawaited(load(silent: true));
        }
      },
      onError: (Object error) {
        debugPrint('ChatListProvider realtime error: $error');
      },
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Optimistically marks unread messages in [chatId] as read and persists.
  Future<bool> markAsRead(String chatId) async {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    Chat? previous;
    if (index != -1) {
      previous = _chats[index];
      final updatedMessages = previous.messages
          .map((m) => m.isRead ? m : m.copyWith(isRead: true))
          .toList();
      _chats[index] = previous.copyWith(messages: updatedMessages);
      notifyListeners();
    }

    final result = await _markChatAsRead(chatId);
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        if (index != -1 && previous != null && index < _chats.length) {
          _chats[index] = previous;
        }
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) => true,
    );
  }

  /// Looks up or creates a 1-to-1 chat with [otherUserId] and refreshes list.
  Future<String?> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  }) async {
    final result = await _getOrCreateChat(
      GetOrCreateChatParams(
        otherUserId: otherUserId,
        maintenanceRequestId: maintenanceRequestId,
      ),
    );
    if (_isDisposed) return null;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (chatId) async {
        await load(silent: true);
        return chatId;
      },
    );
  }

  /// Updates the cached preview when [ConversationProvider] sends a message.
  void applySentMessage(String chatId, Message message) {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index == -1) return;

    final chat = _chats[index];
    if (chat.messages.any((m) => m.id == message.id)) return;

    final updatedMessages = [message, ...chat.messages];
    final updatedChat = chat.copyWith(
      messages: updatedMessages,
      lastMessageTime: message.timestamp,
    );
    _chats
      ..removeAt(index)
      ..insert(0, updatedChat);
    notifyListeners();
  }

  /// Clears cached messages locally for [chatId] without deleting the thread.
  void clearChat(String chatId) {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index == -1) return;
    _chats[index] = _chats[index].copyWith(messages: const []);
    notifyListeners();
  }

  Future<bool> deleteChat(String chatId) => deleteMultipleChats([chatId]);

  /// Optimistically deletes [chatIds] and reverts + exposes [errorMessage] on failure.
  Future<bool> deleteMultipleChats(List<String> chatIds) async {
    if (chatIds.isEmpty) return true;

    final snapshot = List<Chat>.from(_chats);
    final idSet = chatIds.toSet();
    _chats.removeWhere((c) => idSet.contains(c.chatId));
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteChats(chatIds);
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        _chats = snapshot;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        unawaited(_syncSubscription());
        return true;
      },
    );
  }

  @override
  void reset() {
    unawaited(_listSubscription?.cancel());
    _listSubscription = null;
    _subscribedChatIds = const [];
    _chats = [];
    _status = ViewStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_listSubscription?.cancel());
    _listSubscription = null;
    super.dispose();
  }
}
