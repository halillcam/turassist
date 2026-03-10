import '../entities/chat_message_entity.dart';
import '../entities/chat_sender_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> observeMessages(String tourId);

  Future<ChatSenderEntity> getCurrentSender();

  Future<void> sendMessage({
    required String tourId,
    required String text,
    required ChatSenderEntity sender,
  });
}
