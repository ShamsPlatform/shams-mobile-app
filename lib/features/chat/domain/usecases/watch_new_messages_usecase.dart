import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Subscribes to newly inserted messages for a single conversation.
class WatchNewMessagesUseCase implements StreamUseCase<Message, String> {
  WatchNewMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Stream<Message> call(String chatId) {
    return _repository.watchNewMessages(chatId);
  }
}
