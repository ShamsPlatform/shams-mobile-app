import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Parameters for looking up or creating a 1-to-1 chat.
class GetOrCreateChatParams {
  final String otherUserId;
  final String? maintenanceRequestId;

  const GetOrCreateChatParams({
    required this.otherUserId,
    this.maintenanceRequestId,
  });
}

/// Finds an existing 1-to-1 chat with [otherUserId] or creates one.
class GetOrCreateChatUseCase
    implements UseCase<String, GetOrCreateChatParams> {
  GetOrCreateChatUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<String>> call(GetOrCreateChatParams params) {
    return _repository.getOrCreateChat(
      otherUserId: params.otherUserId,
      maintenanceRequestId: params.maintenanceRequestId,
    );
  }
}
