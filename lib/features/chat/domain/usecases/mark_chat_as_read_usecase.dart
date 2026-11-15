import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Marks all unread incoming messages in a chat as read.
class MarkChatAsReadUseCase implements UseCase<void, String> {
  MarkChatAsReadUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(String chatId) {
    return _repository.markChatAsRead(chatId);
  }
}
