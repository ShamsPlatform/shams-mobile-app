import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Fetches all chats for the signed-in user, sorted by latest activity.
class GetChatsUseCase implements UseCase<List<Chat>, NoParams> {
  GetChatsUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<List<Chat>>> call(NoParams params) {
    return _repository.getChats();
  }
}
