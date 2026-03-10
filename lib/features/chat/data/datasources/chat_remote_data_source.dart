import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secured_shared_preferences.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/chat_service.dart';
import '../models/chat_message_model.dart';
import '../models/chat_sender_model.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource({
    ChatService? chatService,
    AuthService? authService,
    SecuredSharedPreferences? storage,
  }) : _chatService = chatService ?? ChatService(),
       _authService = authService ?? AuthService(),
       _storage = storage ?? SecuredSharedPreferences();

  final ChatService _chatService;
  final AuthService _authService;
  final SecuredSharedPreferences _storage;

  Stream<List<ChatMessageModel>> observeMessages(String tourId) {
    return _chatService
        .getChatMessages(tourId)
        .map((messages) => messages.map(ChatMessageModel.fromLegacy).toList());
  }

  Future<void> sendMessage({required String tourId, required ChatMessageModel message}) {
    return _chatService.sendChatMessage(tourId, message.toLegacy());
  }

  Future<ChatSenderModel> getCurrentSender() async {
    final profile = await _authService.getUserProfile();
    if (profile != null) {
      final name = profile.fullName.trim().isEmpty ? 'Misafir' : profile.fullName.trim();
      return ChatSenderModel(userId: profile.uid, displayName: name, role: profile.role);
    }

    final cachedGuideId = (await _storage.readString(StorageKeys.guideId) ?? '').trim();
    final cachedGuideName = (await _storage.readString(StorageKeys.guideName) ?? '').trim();
    final isGuideSession = await _storage.readBool(StorageKeys.isGuideSession);

    if (isGuideSession || cachedGuideId.isNotEmpty) {
      final guideId = cachedGuideId.isEmpty ? _authService.getCurrentUserId() : cachedGuideId;
      final guideName = await _authService.getGuideFullName(
        guideId,
        defaultName: cachedGuideName.isEmpty ? 'Tur Sorumlusu' : cachedGuideName,
      );
      return ChatSenderModel(userId: guideId, displayName: guideName, role: 'guide');
    }

    final userId = _authService.getCurrentUserId();
    return ChatSenderModel(
      userId: userId,
      displayName: userId.isEmpty ? 'Misafir' : 'Katılımcı',
      role: 'customer',
    );
  }
}
