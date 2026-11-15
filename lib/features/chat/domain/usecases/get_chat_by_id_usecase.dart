import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Fetches a single chat thread by its identifier.
class GetChatByIdUseCase implements UseCase<Chat?, String> {
  GetChatByIdUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<Chat?>> call(String chatId) {
    return _repository.getChatById(chatId);
  }
}
