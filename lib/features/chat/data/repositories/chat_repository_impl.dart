import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_sender_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatRemoteDataSource();

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<ChatSenderEntity> getCurrentSender() {
    return _remoteDataSource.getCurrentSender();
  }

  @override
  Stream<List<ChatMessageEntity>> observeMessages(String tourId) {
    return _remoteDataSource.observeMessages(tourId);
  }

  @override
  Future<void> sendMessage({
    required String tourId,
    required String text,
    required ChatSenderEntity sender,
  }) {
    final message = ChatMessageModel(
      id: '',
      senderId: sender.userId,
      senderName: sender.displayName,
      senderRole: sender.role,
      text: text,
      createdAt: DateTime.now(),
    );
    return _remoteDataSource.sendMessage(tourId: tourId, message: message);
  }
}
