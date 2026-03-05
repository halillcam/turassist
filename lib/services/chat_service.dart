import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement_model.dart';
import '../models/chat_model.dart';

/// Tur sohbet mesajları ve duyuru yönetimi servisi.
///
/// Sorumlulukları:
/// - Sohbet mesajlarını gönderme, anlık stream ve tek seferlik listeleme
/// - Mesaj silme
/// - Duyuru oluşturma, anlık stream ve tek seferlik listeleme
/// - Duyuru silme
/// - QR okutan katılımcılara Firestore bildirimi gönderme
/// - Müşteri tarafı fallback bildirimleri (Firestore Rules kısıtlı erişim)
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SOHBET MESAJLARI ====================

  /// Yeni sohbet mesajını ilgili turun 'messages' alt koleksiyonuna ekler.
  Future<void> sendChatMessage(String tourId, ChatModel message) async {
    debugPrint('ChatService.sendChatMessage: tourId=$tourId, sender=${message.senderName}');
    final ref = _firestore.collection('tours').doc(tourId).collection('messages');
    final docRef = await ref.add(message.toJson());
    debugPrint('ChatService.sendChatMessage: BAŞARILI ✓ docId=${docRef.id}');
  }

  /// Tur mesajlarını kronolojik sırayla (eskiden yeniye) anlık dinler.
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

  /// Tüm mesajları tek seferlik getirir (stream gerektirmeyen kullanım için).
  Future<List<ChatModel>> getAllChatMessages(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map(ChatModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('ChatService.getAllChatMessages Error: $e');
      return [];
    }
  }

  /// Belirtilen mesajı ilgili turun mesajlar koleksiyonundan siler.
  Future<void> deleteChatMessage(String tourId, String messageId) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      debugPrint('ChatService.deleteChatMessage Error: $e');
    }
  }

  // ==================== DUYURULAR ====================

  /// Yeni duyuruyu ilgili turun 'announcements' alt koleksiyonuna ekler.
  Future<void> createAnnouncement(String tourId, AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .add(announcement.toJson());
    } catch (e) {
      debugPrint('ChatService.createAnnouncement Error: $e');
      throw Exception('Duyuru kaydedilemedi: $e');
    }
  }

  /// Tur duyurularını yeniden eskiye anlık dinler.
  Stream<List<AnnouncementModel>> getAnnouncements(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AnnouncementModel.fromFirestore).toList());
  }

  /// Kullanıcının `/users/{uid}/notifications` koleksiyonundan tura ait
  /// bildirimleri anlık dinler.
  ///
  /// Müşteri, 'announcements' koleksiyonunu okuma iznine sahip olmadığında
  /// fallback olarak kullanılır.
  Stream<List<AnnouncementModel>> getUserTourNotifications(String userId, String tourId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('tourId', isEqualTo: tourId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            return AnnouncementModel(
              id: doc.id,
              notification: data['message']?.toString() ?? '',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Tüm duyuruları tek seferlik getirir (yeniden eskiye sıralı).
  Future<List<AnnouncementModel>> getAllAnnouncements(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(AnnouncementModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('ChatService.getAllAnnouncements Error: $e');
      return [];
    }
  }

  /// Belirtilen duyuruyu ilgili turun duyurular koleksiyonundan siler.
  Future<void> deleteAnnouncement(String tourId, String announcementId) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .doc(announcementId)
          .delete();
    } catch (e) {
      debugPrint('ChatService.deleteAnnouncement Error: $e');
    }
  }

  // ==================== BİLDİRİM GÖNDERİMİ ====================

  /// QR okutarak check-in yapmış tur katılımcılarına Firestore bildirimi gönderir.
  ///
  /// Her katılımcının `/users/{uid}/notifications` koleksiyonuna bir belge
  /// oluşturulur. Cloud Functions bu koleksiyonu izleyerek FCM push
  /// bildirimi iletmekle sorumludur.
  Future<void> sendNotificationToTourParticipants(String tourId, String message) async {
    try {
      // Turun check-in yapmış katılımcı biletlerini getir
      final tickets = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('isScanned', isEqualTo: true)
          .get();

      final uniqueUserIds = <String>{};
      for (final doc in tickets.docs) {
        final userId = doc.data()['userId']?.toString().trim() ?? '';
        if (userId.isNotEmpty) uniqueUserIds.add(userId);
      }

      // Her kullanıcı için tek bildirim kaydı oluştur
      for (final userId in uniqueUserIds) {
        await _firestore.collection('users').doc(userId).collection('notifications').add({
          'title': 'Tur Bildirim',
          'message': message,
          'tourId': tourId,
          'scope': 'checked_in_only',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      debugPrint('ChatService.sendNotificationToTourParticipants Error: $e');
      throw Exception('Katılımcı bildirimleri kaydedilemedi: $e');
    }
  }
}
