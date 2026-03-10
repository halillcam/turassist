import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class ObserveChatMessagesUseCase {
  ObserveChatMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatMessageEntity>> execute(String tourId) {
    return _repository.observeMessages(tourId);
  }
}
