import 'package:flutter_test/flutter_test.dart';
import 'package:shams_mobile_app/features/chat/data/models/chat_model.dart';
import 'package:shams_mobile_app/features/chat/data/models/message_model.dart';

void main() {
  group('MessageModel.fromJson', () {
    test('maps full Supabase message payload accurately', () {
      final msg = MessageModel.fromJson({
        'id': 'm1',
        'sender_id': 'u1',
        'text': 'مرحبا بكم',
        'created_at': '2026-11-15T10:00:00.000Z',
        'is_read': true,
      });

      expect(msg.id, 'm1');
      expect(msg.senderId, 'u1');
      expect(msg.text, 'مرحبا بكم');
      expect(msg.timestamp, DateTime.utc(2026, 11, 15, 10));
      expect(msg.isRead, isTrue);
    });

    test('applies safe defaults for missing fields', () {
      final msg = MessageModel.fromJson(const {});
      expect(msg.id, '');
      expect(msg.senderId, '');
      expect(msg.text, '');
      expect(msg.isRead, isFalse);
    });
  });

  group('ChatModel.fromJson', () {
    test('maps participants and sorts nested messages newest-first', () {
      final chat = ChatModel.fromJson({
        'id': 'c1',
        'maintenance_req_id': 'mr1',
        'last_message_at': '2026-11-15T12:00:00.000Z',
        'chat_participants': [
          {
            'profiles': {
              'id': 'u1',
              'name': 'علي',
              'username': 'ali',
              'profile_image_url': 'https://cdn.example/a.png',
            },
          },
          {
            'profiles': {
              'id': 'u2',
              'name': 'ورشة النور',
            },
          },
        ],
        'messages': [
          {
            'id': 'm1',
            'sender_id': 'u1',
            'text': 'الأولى',
            'created_at': '2026-11-15T10:00:00.000Z',
            'is_read': true,
          },
          {
            'id': 'm2',
            'sender_id': 'u2',
            'text': 'الأحدث',
            'created_at': '2026-11-15T12:00:00.000Z',
            'is_read': false,
          },
        ],
      });

      expect(chat.chatId, 'c1');
      expect(chat.maintenanceRequestId, 'mr1');
      expect(chat.lastMessageTime, DateTime.utc(2026, 11, 15, 12));
      expect(chat.participants.map((p) => p.id), ['u1', 'u2']);
      expect(chat.participants.first.name, 'علي');
      expect(chat.messages.map((m) => m.id), ['m2', 'm1']);
    });
  });
}
