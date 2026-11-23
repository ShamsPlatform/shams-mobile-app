import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for chat conversations, messages, and realtime updates.
abstract interface class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchChats();

  Future<Map<String, dynamic>?> fetchChatById(String chatId);

  Future<String?> fetchChatIdByMaintenanceRequest(String requestId);

  Future<String> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  });

  Future<List<Map<String, dynamic>>> fetchMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  });

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
  });

  Future<void> markChatAsRead(String chatId);

  Future<void> deleteChats(List<String> chatIds);

  Stream<Map<String, dynamic>> watchNewMessages(String chatId);

  Stream<void> watchChatListChanges(List<String> chatIds);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(
    this._db, {
    bool useDbNotificationTriggers = false,
  }) : _useDbNotificationTriggers = useDbNotificationTriggers;

  final SupabaseClient _db;
  final bool _useDbNotificationTriggers;

  static const _chatSelect = '''
    *,
    chat_participants(
      profiles!chat_participants_user_id_fkey(id, name, username, profile_image_url)
    ),
    messages(id, text, sender_id, is_read, created_at)
  ''';

  String _requireUserId() {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('لا يوجد مستخدم مسجل دخول');
    }
    return user.id;
  }

  Future<T> _guardDb<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      debugPrint(
        'Chat PostgrestException [${e.code}]: ${e.message} '
        '(details: ${e.details}, hint: ${e.hint})',
      );
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  @override
  Future<String> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  }) {
    return _guardDb(() async {
      final userId = _requireUserId();

      final myChats = await _db
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', userId);

      final otherChats = await _db
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', otherUserId);

      final myIds = myChats.map((r) => r['chat_id']).toSet();
      final otherIds = otherChats.map((r) => r['chat_id']).toSet();
      final commonIds = myIds.intersection(otherIds);

      if (commonIds.isNotEmpty) {
        final chatId = commonIds.first as String;
        if (maintenanceRequestId != null) {
          try {
            await _db.from('chats').update({
              'maintenance_req_id': maintenanceRequestId,
            }).eq('id', chatId);
          } catch (e) {
            debugPrint('Error updating chat maintenance request id: $e');
          }
        }
        return chatId;
      }

      final dynamic resultId = await _db.rpc(
        'create_new_chat',
        params: {
          'other_user_uuid': otherUserId,
          'maintenance_req_uuid': maintenanceRequestId,
        },
      );

      return resultId as String;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChats() {
    return _guardDb(() async {
      final userId = _requireUserId();

      final participantRows = await _db
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', userId);

      final chatIds =
          participantRows.map((r) => r['chat_id'] as String).toList();
      if (chatIds.isEmpty) return [];

      return await _db
          .from('chats')
          .select(_chatSelect)
          .inFilter('id', chatIds)
          .order('last_message_at', ascending: false);
    });
  }

  @override
  Future<Map<String, dynamic>?> fetchChatById(String chatId) {
    return _guardDb(() async {
      return await _db
          .from('chats')
          .select(_chatSelect)
          .eq('id', chatId)
          .maybeSingle();
    });
  }

  @override
  Future<String?> fetchChatIdByMaintenanceRequest(String requestId) {
    return _guardDb(() async {
      final row = await _db
          .from('chats')
          .select('id')
          .eq('maintenance_req_id', requestId)
          .maybeSingle();
      return row?['id'] as String?;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) {
    return _guardDb(() async {
      return await _db
          .from('messages')
          .select('''
            *,
            profiles!messages_sender_id_fkey(id, name, profile_image_url)
          ''')
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
    });
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
  }) {
    return _guardDb(() async {
      final userId = _requireUserId();
      final message = await _db
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': userId,
            'text': text,
          })
          .select()
          .single();

      if (!_useDbNotificationTriggers) {
        // Fire-and-forget notification so message send stays responsive.
        unawaited(
          _createMessageNotification(
            chatId: chatId,
            senderId: userId,
            text: text,
          ),
        );
      }

      return message;
    });
  }

  Future<void> _createMessageNotification({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final participants = await _db
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', chatId)
          .neq('user_id', senderId);

      if (participants.isNotEmpty) {
        final recipientId = participants.first['user_id'] as String;

        final senderProfile = await _db
            .from('profiles')
            .select('name')
            .eq('id', senderId)
            .maybeSingle();
        final senderName = senderProfile?['name'] ?? 'مستخدم شمس';

        await _db.from('notifications').insert({
          'user_id': recipientId,
          'title': 'رسالة جديدة',
          'message': 'أرسل $senderName: $text',
          'type': 'message',
          'target_id': chatId,
        });
      }
    } catch (e) {
      debugPrint('Error creating message notification: $e');
    }
  }

  @override
  Future<void> markChatAsRead(String chatId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    });
  }

  @override
  Future<void> deleteChats(List<String> chatIds) {
    return _guardDb(() async {
      if (chatIds.isEmpty) return;
      await _db.from('chats').delete().inFilter('id', chatIds);
    });
  }

  @override
  Stream<Map<String, dynamic>> watchNewMessages(String chatId) {
    late final RealtimeChannel channel;
    final controller = StreamController<Map<String, dynamic>>(
      onCancel: () => _db.removeChannel(channel),
    );
    channel = _db
        .channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add(Map<String, dynamic>.from(payload.newRecord));
            }
          },
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Stream<void> watchChatListChanges(List<String> chatIds) {
    if (chatIds.isEmpty) {
      return const Stream.empty();
    }
    late final RealtimeChannel channel;
    final controller = StreamController<void>(
      onCancel: () => _db.removeChannel(channel),
    );
    channel = _db
        .channel('chat-list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter,
            column: 'chat_id',
            value: chatIds,
          ),
          callback: (_) {
            if (!controller.isClosed) {
              controller.add(null);
            }
          },
        )
        .subscribe();
    return controller.stream;
  }
}
