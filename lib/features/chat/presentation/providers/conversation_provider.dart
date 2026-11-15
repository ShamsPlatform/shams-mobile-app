import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_new_messages_usecase.dart';

/// Per-screen provider managing a single conversation's messages and realtime
/// channel. Automatically closes the channel on [dispose].
class ConversationProvider extends ChangeNotifier {
  ConversationProvider({
    required GetChatByIdUseCase getChatById,
    required GetMessagesUseCase getMessages,
    required SendMessageUseCase sendMessage,
    required MarkChatAsReadUseCase markChatAsRead,
    required WatchNewMessagesUseCase watchNewMessages,
  })  : _getChatById = getChatById,
        _getMessages = getMessages,
        _sendMessage = sendMessage,
        _markChatAsRead = markChatAsRead,
        _watchNewMessages = watchNewMessages;

  static const _tempIdPrefix = '__pending_';
  static int _tempCounter = 0;

  final GetChatByIdUseCase _getChatById;
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final MarkChatAsReadUseCase _markChatAsRead;
  final WatchNewMessagesUseCase _watchNewMessages;

  void Function(String chatId, Message message)? _onMessageSent;
  void Function(String chatId)? _onCleared;

  String _chatId = '';
  Chat? _chat;
  List<Message> _messages = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;
  StreamSubscription<Message>? _messageSubscription;
  bool _isDisposed = false;

  String get chatId => _chatId;
  Chat? get chat => _chat;
  List<Message> get messages => List.unmodifiable(_messages);
  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void setSyncCallbacks({
    void Function(String chatId, Message message)? onMessageSent,
    void Function(String chatId)? onCleared,
  }) {
    _onMessageSent = onMessageSent;
    _onCleared = onCleared;
  }

  /// Opens [chatId], primes state from [initialChat] if available, subscribes
  /// to incoming messages, marks existing incoming messages as read, and loads
  /// the latest messages from the repository.
  Future<void> open(String chatId, {Chat? initialChat}) async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    _chatId = chatId;
    _chat = initialChat;
    _messages = initialChat != null
        ? List<Message>.from(initialChat.messages)
        : [];
    _status = initialChat != null ? ViewStatus.success : ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _messageSubscription = _watchNewMessages(chatId).listen(
      _onRealtimeMessage,
      onError: (Object error) {
        debugPrint('ConversationProvider realtime error: $error');
      },
    );

    unawaited(_markChatAsRead(chatId));

    final Future<void> metaFuture = initialChat == null
        ? _loadChatMetadata(chatId)
        : Future<void>.value();
    await Future.wait([metaFuture, _loadMessages(chatId)]);
  }

  Future<void> _loadChatMetadata(String chatId) async {
    final result = await _getChatById(chatId);
    if (_isDisposed || _chatId != chatId) return;

    result.fold(
      (failure) {
        _errorMessage ??= failure.message;
      },
      (fetchedChat) {
        if (fetchedChat != null) {
          _chat = fetchedChat;
          _mergeMessages(fetchedChat.messages);
          notifyListeners();
        }
      },
    );
  }

  Future<void> _loadMessages(String chatId) async {
    final result = await _getMessages(GetMessagesParams(chatId: chatId));
    if (_isDisposed || _chatId != chatId) return;

    result.fold(
      (failure) {
        if (_messages.isEmpty) {
          _status = ViewStatus.failure;
        }
        _errorMessage = failure.message;
        notifyListeners();
      },
      (fetched) {
        _mergeMessages(fetched);
        _status = ViewStatus.success;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  void _mergeMessages(List<Message> incoming) {
    final knownIds = _messages.map((m) => m.id).toSet();
    final pending = _messages
        .where((m) => m.id.startsWith(_tempIdPrefix))
        .toList(growable: false);

    final merged = List<Message>.from(_messages);
    for (final msg in incoming) {
      if (knownIds.add(msg.id)) {
        merged.add(msg);
      }
    }
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Keep optimistic unsent messages pinned above server order until reconciled.
    final serverMessages = merged
        .where((m) => !m.id.startsWith(_tempIdPrefix))
        .toList();
    _messages = [...pending, ...serverMessages];
  }

  void _onRealtimeMessage(Message incoming) {
    if (_isDisposed) return;

    if (_messages.any((m) => m.id == incoming.id)) {
      return;
    }

    final pendingIndex = _messages.indexWhere(
      (m) =>
          m.id.startsWith(_tempIdPrefix) &&
          m.senderId == incoming.senderId &&
          m.text == incoming.text,
    );
    if (pendingIndex != -1) {
      _messages[pendingIndex] = incoming;
    } else {
      _messages.insert(0, incoming);
    }

    _onMessageSent?.call(_chatId, incoming);
    unawaited(_markChatAsRead(_chatId));
    notifyListeners();
  }

  /// Sends [text] with an optimistic local insert, reconciling with the saved
  /// server message on `Ok` or reverting and setting [errorMessage] on `Err`.
  Future<bool> sendMessage({
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty || _chatId.isEmpty) return false;

    final tempId = '$_tempIdPrefix${++_tempCounter}';
    final optimistic = Message(
      id: tempId,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messages.insert(0, optimistic);
    _errorMessage = null;
    notifyListeners();

    final result = await _sendMessage(
      SendMessageParams(chatId: _chatId, text: text),
    );
    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        _messages.removeWhere((m) => m.id == tempId);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (saved) {
        _messages.removeWhere((m) => m.id == tempId);
        if (!_messages.any((m) => m.id == saved.id)) {
          _messages.insert(0, saved);
        }
        _onMessageSent?.call(_chatId, saved);
        notifyListeners();
        return true;
      },
    );
  }

  /// Clears visible messages locally for this conversation.
  void clearMessages() {
    _messages = [];
    if (_chatId.isNotEmpty) {
      _onCleared?.call(_chatId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_messageSubscription?.cancel());
    _messageSubscription = null;
    super.dispose();
  }
}
