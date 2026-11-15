import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_new_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/conversation_provider.dart';

class MockGetChatByIdUseCase extends Mock implements GetChatByIdUseCase {}

class MockGetMessagesUseCase extends Mock implements GetMessagesUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

class MockMarkChatAsReadUseCase extends Mock implements MarkChatAsReadUseCase {}

class MockWatchNewMessagesUseCase extends Mock
    implements WatchNewMessagesUseCase {}

void main() {
  late MockGetChatByIdUseCase getChatById;
  late MockGetMessagesUseCase getMessages;
  late MockSendMessageUseCase sendMessage;
  late MockMarkChatAsReadUseCase markChatAsRead;
  late MockWatchNewMessagesUseCase watchNewMessages;

  final t1 = DateTime.utc(2026, 11, 15, 10, 0);
  final t2 = DateTime.utc(2026, 11, 15, 10, 5);
  final msg1 = Message(
    id: 'm1',
    senderId: 'u2',
    text: 'أهلاً',
    timestamp: t1,
  );
  final initialChat = Chat(
    chatId: 'c1',
    participants: const [AppUser(id: 'u2', name: 'ورشة', email: '')],
    messages: [msg1],
    lastMessageTime: t1,
  );

  setUpAll(() {
    registerFallbackValue(const GetMessagesParams(chatId: 'c1'));
    registerFallbackValue(const SendMessageParams(chatId: 'c1', text: ''));
  });

  setUp(() {
    getChatById = MockGetChatByIdUseCase();
    getMessages = MockGetMessagesUseCase();
    sendMessage = MockSendMessageUseCase();
    markChatAsRead = MockMarkChatAsReadUseCase();
    watchNewMessages = MockWatchNewMessagesUseCase();

    when(() => markChatAsRead(any()))
        .thenAnswer((_) async => const Ok(null));
  });

  ConversationProvider createProvider() => ConversationProvider(
        getChatById: getChatById,
        getMessages: getMessages,
        sendMessage: sendMessage,
        markChatAsRead: markChatAsRead,
        watchNewMessages: watchNewMessages,
      );

  test('open primes initialChat, subscribes, marks read, and loads metadata if missing',
      () async {
    final stream = StreamController<Message>();
    addTearDown(stream.close);

    when(() => watchNewMessages('c1')).thenAnswer((_) => stream.stream);
    when(() => getChatById('c1')).thenAnswer((_) async => Ok(initialChat));
    when(() => getMessages(any())).thenAnswer((_) async => Ok([msg1]));

    final provider = createProvider();
    addTearDown(provider.dispose);

    await provider.open('c1');

    expect(provider.status, ViewStatus.success);
    expect(provider.chat?.chatId, 'c1');
    expect(provider.messages, [msg1]);
    verify(() => markChatAsRead('c1')).called(1);
    verify(() => getChatById('c1')).called(1);
  });

  test('sendMessage performs optimistic insert, reconciles with realtime/server, and notifies ChatList callback',
      () async {
    final stream = StreamController<Message>();
    addTearDown(stream.close);
    when(() => watchNewMessages('c1')).thenAnswer((_) => stream.stream);
    when(() => getMessages(any())).thenAnswer((_) async => Ok([msg1]));

    final savedCompleter = Completer<Result<Message>>();
    when(() => sendMessage(any())).thenAnswer((_) => savedCompleter.future);

    final synced = <Message>[];
    final provider = createProvider()
      ..setSyncCallbacks(onMessageSent: (_, m) => synced.add(m));
    addTearDown(provider.dispose);

    await provider.open('c1', initialChat: initialChat);

    final sendFuture = provider.sendMessage(senderId: 'u1', text: 'السلام عليكم');
    expect(provider.messages.length, 2);
    expect(provider.messages.first.text, 'السلام عليكم');

    final serverMsg = Message(
      id: 'm2',
      senderId: 'u1',
      text: 'السلام عليكم',
      timestamp: t2,
    );
    // Simulate realtime event arriving BEFORE send RPC returns, then ALSO RPC returning.
    stream.add(serverMsg);
    await pumpEventQueue();
    savedCompleter.complete(Ok(serverMsg));

    final ok = await sendFuture;
    expect(ok, isTrue);
    expect(provider.messages.where((m) => m.id == 'm2').length, 1);
    expect(provider.messages.map((m) => m.id), ['m2', 'm1']);
    expect(synced.map((m) => m.id), ['m2', 'm2']);
  });

  test('sendMessage reverts optimistic insert and sets errorMessage on Err',
      () async {
    final stream = StreamController<Message>();
    addTearDown(stream.close);
    when(() => watchNewMessages('c1')).thenAnswer((_) => stream.stream);
    when(() => getMessages(any())).thenAnswer((_) async => Ok([msg1]));
    when(() => sendMessage(any()))
        .thenAnswer((_) async => const Err(NetworkFailure()));

    final provider = createProvider();
    addTearDown(provider.dispose);
    await provider.open('c1', initialChat: initialChat);

    final ok = await provider.sendMessage(senderId: 'u1', text: 'فشل');

    expect(ok, isFalse);
    expect(provider.messages, [msg1]);
    expect(provider.errorMessage, isNotNull);
  });

  test('reopening/disposing 10 times cancels previous channels cleanly with no duplicates',
      () async {
    var activeSubscriptions = 0;
    final messageStreams = <StreamController<Message>>[];

    when(() => getMessages(any())).thenAnswer((_) async => Ok([msg1]));
    when(() => watchNewMessages('c1')).thenAnswer((_) {
      activeSubscriptions++;
      final c = StreamController<Message>(
        onCancel: () => activeSubscriptions--,
      );
      messageStreams.add(c);
      return c.stream;
    });

    for (var i = 0; i < 10; i++) {
      final provider = createProvider();
      await provider.open('c1', initialChat: initialChat);
      expect(activeSubscriptions, 1);
      provider.dispose();
      await pumpEventQueue();
      expect(activeSubscriptions, 0);
    }

    for (final c in messageStreams) {
      await c.close();
    }
  });

  test('clearMessages wipes local list and notifies onCleared', () async {
    final stream = StreamController<Message>();
    addTearDown(stream.close);
    when(() => watchNewMessages('c1')).thenAnswer((_) => stream.stream);
    when(() => getMessages(any())).thenAnswer((_) async => Ok([msg1]));

    String? clearedChatId;
    final provider = createProvider()
      ..setSyncCallbacks(onCleared: (id) => clearedChatId = id);
    addTearDown(provider.dispose);

    await provider.open('c1', initialChat: initialChat);
    provider.clearMessages();

    expect(provider.messages, isEmpty);
    expect(clearedChatId, 'c1');
  });
}
