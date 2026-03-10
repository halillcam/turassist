import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendChatMessage(String tourId, ChatModel message) async {
    debugPrint('ChatService.sendChatMessage: tourId=$tourId, sender=${message.senderName}');
    final ref = _firestore.collection('tours').doc(tourId).collection('messages');
    final docRef = await ref.add(message.toJson());
    debugPrint('ChatService.sendChatMessage: BAŞARILI ✓ docId=${docRef.id}');
  }

  Stream<List<ChatModel>> getChatMessages(String tourId) {
    debugPrint('ChatService.getChatMessages: Stream başlatılıyor → tours/$tourId/messages');
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          debugPrint('ChatService.getChatMessages: ${snapshot.docs.length} mesaj alındı');
          return snapshot.docs.map(ChatModel.fromFirestore).toList();
        });
  }

  Future<List<ChatModel>> getAllChatMessages(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map(ChatModel.fromFirestore).toList();
    } catch (error) {
      debugPrint('ChatService.getAllChatMessages Error: $error');
      return [];
    }
  }

  Future<void> deleteChatMessage(String tourId, String messageId) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (error) {
      debugPrint('ChatService.deleteChatMessage Error: $error');
    }
  }
}
