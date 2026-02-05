import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/chat_model.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var messages = <ChatModel>[].obs;

  // Mesajları anlık dinle (Stream)
  void listenMessages(String tourId) {
    _firebaseService.getChatMessages(tourId).listen((data) {
      messages.assignAll(data);
    });
  }

  // Mesaj gönder
  Future<void> sendMessage({
    required String tourId,
    required String text,
    required String senderName,
    required String senderId,
  }) async {
    // Gönderilen metni bir ChatModel objesine dönüştürüyoruz
    ChatModel newMessage = ChatModel(
      id: '', // Firestore otomatik ID atayacak
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );

    // Servise objeyi gönderiyoruz (Servis artık sadece tourId ve objeyi bekliyor)
    await _firebaseService.sendChatMessage(tourId, newMessage);
  }
}
