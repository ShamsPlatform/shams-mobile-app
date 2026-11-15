import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Deletes one or more chats by their identifiers.
class DeleteChatsUseCase implements UseCase<void, List<String>> {
  DeleteChatsUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(List<String> chatIds) {
    if (chatIds.isEmpty) {
      return Future.value(const Ok(null));
    }
    return _repository.deleteChats(chatIds);
  }
}
