import '../entities/chat_sender_entity.dart';
import '../repositories/chat_repository.dart';

class SendChatMessageUseCase {
  SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<void> execute({
    required String tourId,
    required String text,
    required ChatSenderEntity sender,
  }) {
    return _repository.sendMessage(tourId: tourId, text: text, sender: sender);
  }
}
