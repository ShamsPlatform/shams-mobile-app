import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';

/// Parameters for sending a message to a chat.
class SendMessageParams {
  final String chatId;
  final String text;

  const SendMessageParams({
    required this.chatId,
    required this.text,
  });
}

/// Sends a text message inside an existing chat conversation.
class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<Message>> call(SendMessageParams params) {
    return _repository.sendMessage(
      chatId: params.chatId,
      text: params.text,
    );
  }
}
