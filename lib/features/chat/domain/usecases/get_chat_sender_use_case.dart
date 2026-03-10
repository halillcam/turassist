import '../entities/chat_sender_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatSenderUseCase {
  GetChatSenderUseCase(this._repository);

  final ChatRepository _repository;

  Future<ChatSenderEntity> execute() {
    return _repository.getCurrentSender();
  }
}
