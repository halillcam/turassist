import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/chat_model.dart';
import '../services/firebase_service.dart';

/// Tur sohbeti controller'ı.
///
/// Firestore stream ile anlık mesaj dinleme, mesaj gönderme
/// ve silme işlemlerini yönetir.
class ChatController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  // ─── Reactive State ───
  final RxList<ChatModel> messages = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentTourId = ''.obs;

  // ─── Stream Yönetimi ───
  StreamSubscription? _messageSubscription;

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }

  // ─── Sohbet Başlatma ───

  /// Tur sohbetini başlatır ve mesajları dinlemeye başlar.
  ///
  /// Önceki stream varsa iptal eder (çoklu dinleyici oluşmasını önler).
  void startTourChat(String tourId) {
    if (tourId.isEmpty) return;

    // Aynı tur zaten dinleniyorsa tekrar başlatma
    if (currentTourId.value == tourId && _messageSubscription != null) return;

    currentTourId.value = tourId;
    _listenMessages(tourId);
  }

  /// Firestore stream ile mesajları anlık dinler.
  ///
  /// Önceki subscription otomatik iptal edilir.
  void _listenMessages(String tourId) {
    _messageSubscription?.cancel();

    debugPrint('ChatController: Stream dinleniyor → tours/$tourId/messages');

    _messageSubscription = _firebaseService.getChatMessages(tourId).listen((data) {
      debugPrint('ChatController: ${data.length} mesaj alındı');
      messages.assignAll(data);
    }, onError: (e) => debugPrint('ChatController: Stream hatası → $e'));
  }

  // ─── Mesaj Gönderme ───

  /// Yeni mesaj gönderir.
  Future<void> sendMessage({
    required String tourId,
    required String text,
    required String senderName,
    required String senderId,
  }) async {
    final newMessage = ChatModel(
      id: '',
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );
    await _firebaseService.sendChatMessage(tourId, newMessage);
    debugPrint('ChatController: Mesaj Firestore\'a yazıldı ✓');
  }

  // ─── Mesaj Silme ───

  /// Belirtilen mesajı siler.
  Future<void> deleteMessage(String tourId, String messageId) async {
    try {
      await _firebaseService.deleteChatMessage(tourId, messageId);
      messages.removeWhere((m) => m.id == messageId);
    } catch (e) {
      debugPrint('Mesaj silme hatası: $e');
    }
  }

  /// Sadece stream aboneliğini iptal eder.
  ///
  /// Reactive state'e dokunmaz — ekran dispose sırasında
  /// Obx rebuild tetiklenmesini (ANR) önler.
  void cancelSubscription() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  /// Dinlemeyi durdurur ve state'i tamamen temizler.
  ///
  /// Yalnızca ekran dispose dışında (örn. manuel temizlik) kullanın.
  /// Ekran dispose sırasında [cancelSubscription] tercih edin.
  void stopListening() {
    cancelSubscription();
    currentTourId.value = '';
    messages.clear();
  }
}
