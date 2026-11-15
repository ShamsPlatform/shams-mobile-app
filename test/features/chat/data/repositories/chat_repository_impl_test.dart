import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:shams_mobile_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late MockChatRemoteDataSource remote;
  late ChatRepositoryImpl repository;

  final chatRow = {
    'id': 'c1',
    'last_message_at': '2026-11-15T10:00:00.000Z',
    'chat_participants': [
      {
        'profiles': {'id': 'u2', 'name': 'فني صيانة'},
      },
    ],
    'messages': [
      {
        'id': 'm1',
        'sender_id': 'u2',
        'text': 'أهلا',
        'created_at': '2026-11-15T10:00:00.000Z',
        'is_read': false,
      },
    ],
  };

  setUp(() {
    remote = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(remote);
  });

  test('getChats maps rows to Chat entities', () async {
    when(() => remote.fetchChats()).thenAnswer((_) async => [chatRow]);

    final result = await repository.getChats();

    expect(result, isA<Ok<List<Chat>>>());
    final chats = (result as Ok<List<Chat>>).data;
    expect(chats, hasLength(1));
    expect(chats.single.chatId, 'c1');
    expect(chats.single.messages.single.text, 'أهلا');
  });

  test('getChats maps ServerException to ServerFailure', () async {
    when(() => remote.fetchChats())
        .thenThrow(const ServerException('query failed'));

    final result = await repository.getChats();
    expect(result, const Err<List<Chat>>(ServerFailure('query failed')));
  });

  test('getChatById returns Ok(null) when chat does not exist', () async {
    when(() => remote.fetchChatById('missing')).thenAnswer((_) async => null);

    final result = await repository.getChatById('missing');
    expect(result, const Ok<Chat?>(null));
  });

  test('getChatById maps row when present', () async {
    when(() => remote.fetchChatById('c1')).thenAnswer((_) async => chatRow);

    final result = await repository.getChatById('c1');
    expect((result as Ok<Chat?>).data?.chatId, 'c1');
  });

  test('getChatIdByMaintenanceRequest forwards chat id lookup', () async {
    when(() => remote.fetchChatIdByMaintenanceRequest('mr1'))
        .thenAnswer((_) async => 'c1');

    final result = await repository.getChatIdByMaintenanceRequest('mr1');
    expect(result, const Ok<String?>('c1'));
  });

  test('sendMessage maps returned row to Message', () async {
    when(() => remote.sendMessage(chatId: 'c1', text: 'سلام')).thenAnswer(
      (_) async => {
        'id': 'm2',
        'sender_id': 'u1',
        'text': 'سلام',
        'created_at': '2026-11-15T10:05:00.000Z',
        'is_read': false,
      },
    );

    final result = await repository.sendMessage(chatId: 'c1', text: 'سلام');
    expect(result, isA<Ok<Message>>());
    expect((result as Ok<Message>).data.id, 'm2');
  });

  test('getMessages delegates limit/offset and maps rows', () async {
    when(() => remote.fetchMessages(chatId: 'c1', limit: 20, offset: 10))
        .thenAnswer(
      (_) async => [
        {
          'id': 'm3',
          'sender_id': 'u1',
          'text': 'صفحة 2',
          'created_at': '2026-11-15T09:00:00.000Z',
          'is_read': true,
        },
      ],
    );

    final result = await repository.getMessages('c1', limit: 20, offset: 10);
    expect((result as Ok<List<Message>>).data.single.id, 'm3');
  });

  test('getOrCreateChat, markChatAsRead, deleteChats delegate and guard errors',
      () async {
    when(
      () => remote.getOrCreateChat(
        otherUserId: 'u2',
        maintenanceRequestId: 'mr1',
      ),
    ).thenAnswer((_) async => 'c1');
    when(() => remote.markChatAsRead('c1')).thenAnswer((_) async {});
    when(() => remote.deleteChats(['c1']))
        .thenThrow(const AppAuthException('unauthenticated'));

    expect(
      await repository.getOrCreateChat(
        otherUserId: 'u2',
        maintenanceRequestId: 'mr1',
      ),
      const Ok('c1'),
    );
    expect(await repository.markChatAsRead('c1'), isA<Ok<void>>());
    expect(
      await repository.deleteChats(['c1']),
      const Err<void>(AuthFailure('unauthenticated')),
    );
  });

  test('watchNewMessages maps stream records to Message entities', () async {
    final controller = StreamController<Map<String, dynamic>>();
    when(() => remote.watchNewMessages('c1'))
        .thenAnswer((_) => controller.stream);

    final received = <Message>[];
    final sub = repository.watchNewMessages('c1').listen(received.add);

    controller.add({
      'id': 'm9',
      'sender_id': 'u2',
      'text': 'فوري',
      'created_at': '2026-11-15T10:15:00.000Z',
      'is_read': false,
    });
    await pumpEventQueue();

    expect(received, hasLength(1));
    expect(received.single.id, 'm9');
    expect(received.single.text, 'فوري');

    await sub.cancel();
    await controller.close();
  });

  test('watchChatListChanges forwards change events', () async {
    final controller = StreamController<void>();
    when(() => remote.watchChatListChanges(['c1']))
        .thenAnswer((_) => controller.stream);

    var events = 0;
    final sub = repository.watchChatListChanges(['c1']).listen((_) => events++);

    controller.add(null);
    await pumpEventQueue();
    expect(events, 1);

    await sub.cancel();
    await controller.close();
  });
}
