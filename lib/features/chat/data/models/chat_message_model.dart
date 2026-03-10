import '../../../../core/models/chat_model.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.text,
    required super.createdAt,
  });

  factory ChatMessageModel.fromLegacy(ChatModel model) {
    return ChatMessageModel(
      id: model.id,
      senderId: model.senderId,
      senderName: model.senderName,
      senderRole: model.senderRole,
      text: model.text,
      createdAt: model.createdAt,
    );
  }

  ChatModel toLegacy() {
    return ChatModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      createdAt: createdAt,
    );
  }
}
