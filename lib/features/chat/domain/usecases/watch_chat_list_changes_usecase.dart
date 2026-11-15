import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Emits whenever messages across any of the user's chats change.
class WatchChatListChangesUseCase
    implements StreamUseCase<void, List<String>> {
  WatchChatListChangesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Stream<void> call(List<String> chatIds) {
    if (chatIds.isEmpty) {
      return const Stream.empty();
    }
    return _repository.watchChatListChanges(chatIds);
  }
}
