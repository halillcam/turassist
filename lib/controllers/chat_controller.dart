import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/chat_model.dart';
import '../services/firebase_service.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var messages = <ChatModel>[].obs;
  var isLoading = false.obs;
  var currentTourId = "".obs;

  // Mesajları anlık dinle (Stream)
  void listenMessages(String tourId) {
    currentTourId.value = tourId;
    _firebaseService.getChatMessages(tourId).listen((data) {
      messages.assignAll(data);
    });
  }

  // Tüm mesajları yükle [cite: 6, 21]
  Future<void> fetchChatMessages(String tourId) async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getAllChatMessages(tourId);
      messages.assignAll(result);
    } catch (e) {
      debugPrint('Mesajları yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mesaj gönder [cite: 6, 21]
  Future<void> sendMessage({
    required String tourId,
    required String text,
    required String senderName,
    required String senderId,
  }) async {
    try {
      // Gönderilen metni bir ChatModel objesine dönüştürüyoruz
      ChatModel newMessage = ChatModel(
        id: '', // Firestore otomatik ID atayacak
        senderId: senderId,
        senderName: senderName, // ███ Adı ve soyadı görünüyor, diğer bilgiler saklanıyor [cite: 6]
        text: text,
        timestamp: DateTime.now(),
      );

      // Servise objeyi gönderiyoruz
      await _firebaseService.sendChatMessage(tourId, newMessage);
    } catch (e) {
      debugPrint('Mesaj gönderme hatası: $e');
    }
  }

  // Tur için chat başlat [cite: 6, 21]
  Future<void> startTourChat(String tourId) async {
    try {
      currentTourId.value = tourId;
      listenMessages(tourId);
      Get.snackbar(
        "Başarılı",
        "Tur chatı açıldı.",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Chat başlatma başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // Mesaj sil [cite: 6]
  Future<void> deleteMessage(String tourId, String messageId) async {
    try {
      await _firebaseService.deleteChatMessage(tourId, messageId);
      messages.removeWhere((m) => m.id == messageId);
    } catch (e) {
      debugPrint('Mesaj silme hatası: $e');
    }
  }
}
