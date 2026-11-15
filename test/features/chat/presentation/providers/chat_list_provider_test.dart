import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/delete_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_chat_list_changes_usecase.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';

class MockGetChatsUseCase extends Mock implements GetChatsUseCase {}

class MockMarkChatAsReadUseCase extends Mock implements MarkChatAsReadUseCase {}

class MockGetOrCreateChatUseCase extends Mock
    implements GetOrCreateChatUseCase {}

class MockDeleteChatsUseCase extends Mock implements DeleteChatsUseCase {}

class MockWatchChatListChangesUseCase extends Mock
    implements WatchChatListChangesUseCase {}

void main() {
  late MockGetChatsUseCase getChats;
  late MockMarkChatAsReadUseCase markChatAsRead;
  late MockGetOrCreateChatUseCase getOrCreateChat;
  late MockDeleteChatsUseCase deleteChats;
  late MockWatchChatListChangesUseCase watchChanges;
  late ChatListProvider provider;

  final t1 = DateTime.utc(2026, 11, 15, 10, 0);
  final t2 = DateTime.utc(2026, 11, 15, 11, 0);

  final unreadMsg = Message(
    id: 'm1',
    senderId: 'u2',
    text: 'مرحبا',
    timestamp: t1,
    isRead: false,
  );
  final chat1 = Chat(
    chatId: 'c1',
    participants: const [AppUser(id: 'u2', name: 'أحمد', email: '')],
    messages: [unreadMsg],
    lastMessageTime: t1,
  );
  final chat2 = Chat(
    chatId: 'c2',
    participants: const [AppUser(id: 'u3', name: 'خالد', email: '')],
    messages: const [],
    lastMessageTime: t2,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetOrCreateChatParams(otherUserId: 'u'));
  });

  setUp(() {
    getChats = MockGetChatsUseCase();
    markChatAsRead = MockMarkChatAsReadUseCase();
    getOrCreateChat = MockGetOrCreateChatUseCase();
    deleteChats = MockDeleteChatsUseCase();
    watchChanges = MockWatchChatListChangesUseCase();

    provider = ChatListProvider(
      getChats: getChats,
      markChatAsRead: markChatAsRead,
      getOrCreateChat: getOrCreateChat,
      deleteChats: deleteChats,
      watchChatListChanges: watchChanges,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  test('load populates chats, sets ViewStatus.success, and subscribes once',
      () async {
    final changesController = StreamController<void>();
    addTearDown(changesController.close);

    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1]));
    when(() => watchChanges(['c1'])).thenAnswer((_) => changesController.stream);

    await provider.load();

    expect(provider.status, ViewStatus.success);
    expect(provider.chats, [chat1]);
    expect(provider.errorMessage, isNull);
    verify(() => watchChanges(['c1'])).called(1);

    // Realtime change triggers silent reload without tearing down identical chatIds sub.
    final statuses = <ViewStatus>[];
    provider.addListener(() => statuses.add(provider.status));
    changesController.add(null);
    await pumpEventQueue();

    expect(statuses, isNot(contains(ViewStatus.loading)));
    verify(() => getChats(any())).called(2);
    verifyNoMoreInteractions(watchChanges);
  });

  test('load resubscribes and cancels previous channel when chat IDs change',
      () async {
    var cancelledFirst = false;
    final c1 = StreamController<void>(onCancel: () => cancelledFirst = true);
    final c2 = StreamController<void>();
    addTearDown(c1.close);
    addTearDown(c2.close);

    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1]));
    when(() => watchChanges(['c1'])).thenAnswer((_) => c1.stream);
    when(() => watchChanges(['c1', 'c2'])).thenAnswer((_) => c2.stream);

    await provider.load();
    expect(cancelledFirst, isFalse);

    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1, chat2]));
    await provider.load(silent: true);

    expect(cancelledFirst, isTrue);
    verify(() => watchChanges(['c1', 'c2'])).called(1);
  });

  test('load sets ViewStatus.failure and errorMessage on Err', () async {
    when(() => getChats(any()))
        .thenAnswer((_) async => const Err(ServerFailure('network down')));

    await provider.load();

    expect(provider.status, ViewStatus.failure);
    expect(provider.errorMessage, 'network down');
  });

  test('markAsRead updates optimistically and reverts on Err', () async {
    final controller = StreamController<void>();
    addTearDown(controller.close);
    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1]));
    when(() => watchChanges(['c1'])).thenAnswer((_) => controller.stream);
    await provider.load();

    when(() => markChatAsRead('c1'))
        .thenAnswer((_) async => const Err(ServerFailure('mark failed')));

    final ok = await provider.markAsRead('c1');
    expect(ok, isFalse);
    expect(provider.chats.single.messages.single.isRead, isFalse);
    expect(provider.errorMessage, 'mark failed');

    when(() => markChatAsRead('c1')).thenAnswer((_) async => const Ok(null));
    final ok2 = await provider.markAsRead('c1');
    expect(ok2, isTrue);
    expect(provider.chats.single.messages.single.isRead, isTrue);
  });

  test('getOrCreateChat reloads chats on Ok and returns null on Err', () async {
    final controller = StreamController<void>();
    addTearDown(controller.close);
    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1]));
    when(() => watchChanges(['c1'])).thenAnswer((_) => controller.stream);
    when(() => getOrCreateChat(any())).thenAnswer((_) async => const Ok('c1'));

    final chatId =
        await provider.getOrCreateChat(otherUserId: 'u2');
    expect(chatId, 'c1');
    verify(() => getChats(any())).called(1);

    when(() => getOrCreateChat(any()))
        .thenAnswer((_) async => const Err(AuthFailure('signed out')));
    final failed =
        await provider.getOrCreateChat(otherUserId: 'u2');
    expect(failed, isNull);
    expect(provider.errorMessage, 'signed out');
  });

  test('applySentMessage moves chat to top and deduplicates identical id',
      () async {
    final controller = StreamController<void>();
    addTearDown(controller.close);
    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1, chat2]));
    when(() => watchChanges(['c1', 'c2'])).thenAnswer((_) => controller.stream);
    await provider.load();

    final sent = Message(
      id: 'm9',
      senderId: 'u1',
      text: 'جديد',
      timestamp: DateTime.utc(2026, 11, 15, 12, 0),
    );
    provider.applySentMessage('c2', sent);
    provider.applySentMessage('c2', sent);

    expect(provider.chats.first.chatId, 'c2');
    expect(provider.chats.first.messages, [sent]);
  });

  test('deleteMultipleChats deletes optimistically and reverts on Err',
      () async {
    final controller = StreamController<void>();
    addTearDown(controller.close);
    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1, chat2]));
    when(() => watchChanges(['c1', 'c2'])).thenAnswer((_) => controller.stream);
    await provider.load();

    when(() => deleteChats(['c1']))
        .thenAnswer((_) async => const Err(ServerFailure('cannot delete')));

    final errDeleted = await provider.deleteChat('c1');
    expect(errDeleted, isFalse);
    expect(provider.chats, [chat1, chat2]);
    expect(provider.errorMessage, 'cannot delete');

    when(() => deleteChats(['c1'])).thenAnswer((_) async => const Ok(null));
    when(() => watchChanges(['c2']))
        .thenAnswer((_) => const Stream.empty());
    final okDeleted = await provider.deleteMultipleChats(['c1']);
    expect(okDeleted, isTrue);
    expect(provider.chats, [chat2]);
  });

  test('reset cancels active realtime subscription and clears state', () async {
    var cancelled = false;
    final controller = StreamController<void>(onCancel: () => cancelled = true);
    addTearDown(controller.close);

    when(() => getChats(any())).thenAnswer((_) async => Ok([chat1]));
    when(() => watchChanges(['c1'])).thenAnswer((_) => controller.stream);
    await provider.load();

    provider.reset();
    await pumpEventQueue();

    expect(cancelled, isTrue);
    expect(provider.chats, isEmpty);
    expect(provider.status, ViewStatus.initial);
    expect(provider.errorMessage, isNull);
  });
}
