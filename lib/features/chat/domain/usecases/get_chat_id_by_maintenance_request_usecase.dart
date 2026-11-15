import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Resolves a chat identifier associated with a maintenance request.
class GetChatIdByMaintenanceRequestUseCase implements UseCase<String?, String> {
  GetChatIdByMaintenanceRequestUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<String?>> call(String requestId) {
    return _repository.getChatIdByMaintenanceRequest(requestId);
  }
}
