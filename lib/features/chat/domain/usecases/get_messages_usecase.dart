import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Parameters for loading paginated messages of a chat.
class GetMessagesParams {
  final String chatId;
  final int limit;
  final int offset;

  const GetMessagesParams({
    required this.chatId,
    this.limit = 50,
    this.offset = 0,
  });
}

/// Loads paginated messages for a single conversation (newest first).
class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  GetMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<List<Message>>> call(GetMessagesParams params) {
    return _repository.getMessages(
      params.chatId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
