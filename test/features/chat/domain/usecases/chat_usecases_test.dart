import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/delete_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_chat_list_changes_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_new_messages_usecase.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;

  final now = DateTime.utc(2026, 11, 15, 10, 0);
  final sampleMessage = Message(
    id: 'm1',
    senderId: 'u1',
    text: 'مرحبا',
    timestamp: now,
  );
  final sampleChat = Chat(
    chatId: 'c1',
    participants: const [AppUser(id: 'u2', name: 'ورشة الشمس', email: '')],
    messages: [sampleMessage],
    lastMessageTime: now,
  );

  setUp(() {
    repo = MockChatRepository();
  });

  test('GetChatsUseCase delegates to repository.getChats', () async {
    when(() => repo.getChats()).thenAnswer((_) async => Ok([sampleChat]));

    final result = await GetChatsUseCase(repo)(const NoParams());
    expect(result, isA<Ok<List<Chat>>>());
    expect((result as Ok<List<Chat>>).data, [sampleChat]);
    verify(() => repo.getChats()).called(1);
  });

  test('GetChatByIdUseCase delegates chatId lookup', () async {
    when(() => repo.getChatById('c1')).thenAnswer((_) async => Ok(sampleChat));

    final result = await GetChatByIdUseCase(repo)('c1');
    expect((result as Ok<Chat?>).data, sampleChat);
    verify(() => repo.getChatById('c1')).called(1);
  });

  test('GetMessagesUseCase passes pagination params to repository', () async {
    when(() => repo.getMessages('c1', limit: 25, offset: 50))
        .thenAnswer((_) async => Ok([sampleMessage]));

    final result = await GetMessagesUseCase(repo)(
      const GetMessagesParams(chatId: 'c1', limit: 25, offset: 50),
    );
    expect((result as Ok<List<Message>>).data, [sampleMessage]);
    verify(() => repo.getMessages('c1', limit: 25, offset: 50)).called(1);
  });

  test('GetOrCreateChatUseCase forwards otherUserId and maintenanceRequestId',
      () async {
    when(
      () => repo.getOrCreateChat(
        otherUserId: 'u2',
        maintenanceRequestId: 'mr1',
      ),
    ).thenAnswer((_) async => const Ok('c1'));

    final result = await GetOrCreateChatUseCase(repo)(
      const GetOrCreateChatParams(
        otherUserId: 'u2',
        maintenanceRequestId: 'mr1',
      ),
    );
    expect(result, const Ok('c1'));
  });

  test('SendMessageUseCase forwards chatId and text and returns Failure on Err',
      () async {
    when(() => repo.sendMessage(chatId: 'c1', text: 'test'))
        .thenAnswer((_) async => const Err(ServerFailure('db error')));

    final result = await SendMessageUseCase(repo)(
      const SendMessageParams(chatId: 'c1', text: 'test'),
    );
    expect(result, const Err<Message>(ServerFailure('db error')));
  });

  test('MarkChatAsReadUseCase delegates markChatAsRead', () async {
    when(() => repo.markChatAsRead('c1'))
        .thenAnswer((_) async => const Ok(null));

    final result = await MarkChatAsReadUseCase(repo)('c1');
    expect(result, isA<Ok<void>>());
    verify(() => repo.markChatAsRead('c1')).called(1);
  });

  group('DeleteChatsUseCase', () {
    test('short-circuits cleanly when chatIds is empty', () async {
      final result = await DeleteChatsUseCase(repo)(const []);
      expect(result, isA<Ok<void>>());
      verifyNever(() => repo.deleteChats(any()));
    });

    test('forwards single and multi-delete lists to repository', () async {
      when(() => repo.deleteChats(['c1', 'c2']))
          .thenAnswer((_) async => const Ok(null));

      final result = await DeleteChatsUseCase(repo)(const ['c1', 'c2']);
      expect(result, isA<Ok<void>>());
      verify(() => repo.deleteChats(['c1', 'c2'])).called(1);
    });
  });

  test('WatchNewMessagesUseCase forwards message stream from repository', () {
    final controller = StreamController<Message>();
    when(() => repo.watchNewMessages('c1')).thenAnswer((_) => controller.stream);

    final stream = WatchNewMessagesUseCase(repo)('c1');
    expectLater(stream, emitsInOrder([sampleMessage, emitsDone]));

    controller.add(sampleMessage);
    controller.close();
  });

  group('WatchChatListChangesUseCase', () {
    test('returns empty stream when chatIds is empty', () async {
      final stream = WatchChatListChangesUseCase(repo)(const []);
      await expectLater(stream, emitsDone);
      verifyNever(() => repo.watchChatListChanges(any()));
    });

    test('forwards change stream when chatIds is non-empty', () async {
      final controller = StreamController<void>();
      when(() => repo.watchChatListChanges(['c1']))
          .thenAnswer((_) => controller.stream);

      final events = <void>[];
      final sub = WatchChatListChangesUseCase(repo)(const ['c1']).listen((_) {
        events.add(null);
      });

      controller.add(null);
      await pumpEventQueue();
      expect(events, hasLength(1));

      await sub.cancel();
      await controller.close();
    });
  });
}
