import 'dart:async';

import 'package:get/get.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_sender_entity.dart';
import '../../domain/usecases/get_chat_sender_use_case.dart';
import '../../domain/usecases/observe_chat_messages_use_case.dart';
import '../../domain/usecases/send_chat_message_use_case.dart';

class ChatController extends GetxController {
  ChatController({
    required GetChatSenderUseCase getChatSenderUseCase,
    required ObserveChatMessagesUseCase observeChatMessagesUseCase,
    required SendChatMessageUseCase sendChatMessageUseCase,
  }) : _getChatSenderUseCase = getChatSenderUseCase,
       _observeChatMessagesUseCase = observeChatMessagesUseCase,
       _sendChatMessageUseCase = sendChatMessageUseCase;

  factory ChatController.createDefault() {
    final repository = ChatRepositoryImpl();
    return ChatController(
      getChatSenderUseCase: GetChatSenderUseCase(repository),
      observeChatMessagesUseCase: ObserveChatMessagesUseCase(repository),
      sendChatMessageUseCase: SendChatMessageUseCase(repository),
    );
  }

  final GetChatSenderUseCase _getChatSenderUseCase;
  final ObserveChatMessagesUseCase _observeChatMessagesUseCase;
  final SendChatMessageUseCase _sendChatMessageUseCase;

  final RxList<ChatMessageEntity> messages = <ChatMessageEntity>[].obs;
  final Rxn<ChatSenderEntity> sender = Rxn<ChatSenderEntity>();
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString tourId = ''.obs;
  final RxString tourTitle = ''.obs;

  StreamSubscription<List<ChatMessageEntity>>? _subscription;

  Future<void> initialize({required String chatTourId, required String chatTourTitle}) async {
    if (tourId.value == chatTourId && _subscription != null) {
      return;
    }

    tourId.value = chatTourId;
    tourTitle.value = chatTourTitle;
    isLoading.value = true;
    errorMessage.value = '';
    sender.value = await _getChatSenderUseCase.execute();
    _subscription?.cancel();
    _subscription = _observeChatMessagesUseCase
        .execute(chatTourId)
        .listen(
          (items) {
            messages.assignAll(items);
            isLoading.value = false;
          },
          onError: (error) {
            errorMessage.value = error.toString();
            isLoading.value = false;
          },
        );
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    final currentSender = sender.value;
    if (text.isEmpty || currentSender == null || tourId.value.isEmpty) {
      return;
    }

    isSending.value = true;
    try {
      await _sendChatMessageUseCase.execute(
        tourId: tourId.value,
        text: text,
        sender: currentSender,
      );
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
