import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement_model.dart';
import '../models/chat_model.dart';
import '../models/ticket_model.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/user_model.dart';

class QrConsumeResult {
  final bool success;
  final String code;
  final String message;

  const QrConsumeResult({required this.success, required this.code, required this.message});
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _normalizeQrToken(String token) {
    return token.trim().replaceAll('\n', '').replaceAll('\r', '').replaceAll('=', '');
  }

  Map<String, dynamic>? _decodeQrPayload(String token) {
    try {
      var normalized = token.trim().replaceAll('\n', '').replaceAll('\r', '');
      final mod = normalized.length % 4;
      if (mod != 0) {
        normalized = normalized.padRight(normalized.length + (4 - mod), '=');
      }
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) return payload;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractTicketIdFromToken(String token) {
    final raw = token.trim();
    if (raw.startsWith('tk_')) {
      final parts = raw.split('_');
      if (parts.length >= 3) {
        return parts[1].trim();
      }
    }

    final payload = _decodeQrPayload(raw);
    return payload?['ticketId']?.toString().trim() ?? '';
  }

  // ==================== TOUR OPERATIONS ====================
  // Aktif (silinmemiş) turları getirir
  Future<List<TourModel>> getActiveTours() async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.map(TourModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error fetching tours: $e');
      return [];
    }
  }

  // Şehre göre filtreleme
  Future<List<TourModel>> getToursByCity(String city) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('city', isEqualTo: city)
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.map(TourModel.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  // Tüm şehirleri getir [cite: 12]
  Future<List<String>> getAllCities() async {
    try {
      final snapshot = await _firestore.collection('cities').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      return [];
    }
  }

  // Tur detayını ID'ye göre getir [cite: 13]
  Future<TourModel?> getTourById(String tourId) async {
    try {
      final doc = await _firestore.collection('tours').doc(tourId).get();
      if (doc.exists) {
        return TourModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching tour: $e');
      return null;
    }
  }

  // Rehbere atanmış aktif turu getir
  Future<TourModel?> getAssignedTourForGuide(String guideId) async {
    try {
      if (guideId.trim().isEmpty) return null;

      final snapshot = await _firestore
          .collection('tours')
          .where('guideId', isEqualTo: guideId)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final tours = snapshot.docs.map(TourModel.fromFirestore).toList();
      tours.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tours.first;
    } catch (e) {
      debugPrint('Error fetching assigned guide tour: $e');
      return null;
    }
  }

  // Tur programını getir (order alanına göre sıralı)
  Future<List<TourProgramDay>> getTourProgram(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('program')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map(TourProgramDay.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error fetching tour program: $e');
      return [];
    }
  }

  // Turu güncelle [cite: 32]
  Future<void> updateTour(String tourId, TourModel tour) async {
    try {
      await _firestore.collection('tours').doc(tourId).update(tour.toJson());
    } catch (e) {
      debugPrint('Error updating tour: $e');
    }
  }

  // Tur katılımcılarını getir [cite: 21, 32]
  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .get();

      final participants = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final status = data['status']?.toString().toLowerCase() ?? '';
          if (status == 'cancelled') return null;

          final userId = data['userId']?.toString().trim() ?? '';
          final ticketName = data['passengerName']?.toString().trim() ?? '';
          final tcNo = data['tcNo']?.toString().trim() ?? '';

          String resolvedName = ticketName;
          if (resolvedName.isEmpty && userId.isNotEmpty) {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            final userData = userDoc.data();
            final profileName = userData?['fullName']?.toString().trim() ?? '';
            final email = userData?['email']?.toString().trim() ?? '';
            final emailName = email.contains('@') ? email.split('@').first.trim() : '';

            resolvedName = profileName.isNotEmpty
                ? profileName
                : (emailName.isNotEmpty ? emailName : resolvedName);

            if (resolvedName.isNotEmpty) {
              await doc.reference.update({'passengerName': resolvedName});
            }
          }

          return {'id': doc.id, ...data, 'passengerName': resolvedName, 'tcNo': tcNo};
        }),
      );

      return participants.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching tour participants: $e');
      return [];
    }
  }

  // Turu bitir [cite: 6, 21, 32]
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      // Tur bitirme talebi oluştur (Admin panele gidecek)
      await _firestore.collection('tours').doc(tourId).update({
        'status': 'finish_requested',
        'finishRequestedBy': guideId,
        'finishRequestedAt': FieldValue.serverTimestamp(),
      });

      // Bu turun tüm QR token'larını pasif hale getir
      final tickets = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .get();

      for (var doc in tickets.docs) {
        await doc.reference.update({'qrToken': null, 'isScanned': true});
      }
    } catch (e) {
      debugPrint('Error finishing tour: $e');
    }
  }

  // ==================== TICKET & QR OPERATIONS ====================
  // Bilet oluşturma [cite: 15, 28]
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) async {
    try {
      debugPrint('createTicket: userId=${ticket.userId}, tourId=${ticket.tourId}');
      debugPrint('createTicket: toJson=${ticket.toJson()}');

      final docRef = _firestore.collection('tickets').doc();
      final tourRef = _firestore.collection('tours').doc(ticket.tourId);
      final userRef = _firestore.collection('users').doc(ticket.userId);
      final qrToken = await generateQRToken(
        ticketId: docRef.id,
        tourId: ticket.tourId,
        userId: ticket.userId,
      );

      final payload = ticket.toJson();
      payload['qrToken'] = qrToken;

      // Kritik yol: müşteri satın alımı için önce sadece bilet kaydı garanti edilir.
      await docRef.set(payload);

      // Ek ilişki alanları (Rules izin verirse) best-effort olarak güncellenir.
      try {
        await tourRef.set({
          'registeredUserIds': FieldValue.arrayUnion([ticket.userId]),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('createTicket: tour registeredUserIds güncellenemedi (izin/rules): $e');
      }

      try {
        await userRef.set({
          'purchasedTourIds': FieldValue.arrayUnion([ticket.tourId]),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('createTicket: user purchasedTourIds güncellenemedi (izin/rules): $e');
      }

      debugPrint('createTicket: BAŞARILI → docId=${docRef.id}');
      return (ticketId: docRef.id, qrToken: qrToken);
    } catch (e) {
      debugPrint('createTicket: HATA → $e');
      throw Exception("Bilet oluşturma başarısız: $e");
    }
  }

  // Kullanıcı profilini getir
  Future<UserModel?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('getUserProfile Error: $e');
      return null;
    }
  }

  // Kullanıcının biletlerini getir [cite: 15]
  Future<List<TicketModel>> getUserTickets() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      debugPrint('getUserTickets: userId=$userId');
      if (userId.isEmpty) {
        debugPrint('getUserTickets: HATA — userId boş!');
        throw Exception("Kullanıcı giriş yapmamış");
      }

      debugPrint('getUserTickets: Firestore sorgusu çalıştırılıyor...');
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('getUserTickets: ${snapshot.docs.length} belge bulundu');
      for (final doc in snapshot.docs) {
        debugPrint('  DOC: id=${doc.id}, data=${doc.data()}');
      }

      final tickets = snapshot.docs.map(TicketModel.fromFirestore).toList();
      // Composite index gerekmeden bellekte sırala
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return tickets;
    } catch (e) {
      debugPrint('getUserTickets: HATA → $e');
      return [];
    }
  }

  // QR Token Gömme - Unique token oluştur [cite: 18, 32]
  Future<String> generateQRToken({
    required String ticketId,
    required String tourId,
    required String userId,
  }) async {
    try {
      final random = Random.secure();
      final nonce =
          '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${random.nextInt(1 << 32).toRadixString(36)}';
      return 'tk_${ticketId}_$nonce';
    } catch (e) {
      debugPrint('QR Token Generation Error: $e');
      throw Exception("QR token oluşturulamadı");
    }
  }

  // QR Token'ı Bilete Kaydet [cite: 18, 32]
  Future<void> updateTicketQRToken(String ticketId, String qrToken) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'qrToken': qrToken});
    } catch (e) {
      debugPrint('QR Token Update Error: $e');
      throw Exception('QR token kaydedilemedi: $e');
    }
  }

  // Rehberin QR okutma işlemi (Security Rules uyumlu: isScanned & scannedAt)
  Future<bool> updateTicketQRStatus(String ticketId) async {
    try {
      final ref = _firestore.collection('tickets').doc(ticketId);
      return await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(ref);
        if (!snapshot.exists) return false;

        final data = snapshot.data() as Map<String, dynamic>;
        final alreadyScanned = data['isScanned'] == true;
        final status = data['status']?.toString().toLowerCase() ?? '';

        if (alreadyScanned || status == 'cancelled' || status == 'completed') {
          return false;
        }

        tx.update(ref, {
          'isScanned': true,
          'status': 'checked_in',
          'scannedAt': FieldValue.serverTimestamp(),
          'qrToken': null,
        });

        return true;
      });
    } catch (e) {
      debugPrint('QR Scan Error: $e');
      return false;
    }
  }

  // QR token ile bilet doğrula + tek seferlik check-in yap (eski uyumlu bool API)
  Future<bool> consumeTicketByQrToken({
    required String qrToken,
    required String expectedTourId,
  }) async {
    final result = await consumeTicketByQrTokenDetailed(
      qrToken: qrToken,
      expectedTourId: expectedTourId,
    );
    return result.success;
  }

  // QR token ile bilet doğrula + tek seferlik check-in yap (detaylı sonuç)
  Future<QrConsumeResult> consumeTicketByQrTokenDetailed({
    required String qrToken,
    required String expectedTourId,
  }) async {
    final normalizedToken = _normalizeQrToken(qrToken);
    final payload = _decodeQrPayload(qrToken);
    final payloadTicketId = _extractTicketIdFromToken(qrToken);
    final payloadTourId = payload?['tourId']?.toString() ?? '';

    if (payloadTourId.isNotEmpty && payloadTourId.trim() != expectedTourId.trim()) {
      debugPrint(
        'consumeTicketByQrToken: Payload tur eşleşmedi. payloadTourId=$payloadTourId expectedTourId=$expectedTourId',
      );
      return const QrConsumeResult(
        success: false,
        code: 'tour_mismatch_payload',
        message: 'QR farklı tura ait görünüyor.',
      );
    }

    try {
      if (normalizedToken.isEmpty || expectedTourId.trim().isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'invalid_input',
          message: 'QR verisi veya tur bilgisi boş.',
        );
      }

      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('tickets')
          .where('qrToken', isEqualTo: normalizedToken)
          .limit(1)
          .get();

      DocumentReference<Map<String, dynamic>>? ref;
      if (query.docs.isNotEmpty) {
        ref = query.docs.first.reference;
      }

      if (ref == null) {
        query = await _firestore
            .collection('tickets')
            .where('qrToken', isEqualTo: qrToken.trim())
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          ref = query.docs.first.reference;
        }
      }

      if (ref == null) {
        if (payloadTicketId.isNotEmpty) {
          final fallbackRef = _firestore.collection('tickets').doc(payloadTicketId);
          final doc = await fallbackRef.get();
          if (doc.exists) {
            ref = fallbackRef;
          }
        }
      }

      if (ref == null) {
        debugPrint('consumeTicketByQrToken: Token bulunamadı');
        return const QrConsumeResult(
          success: false,
          code: 'token_not_found',
          message: 'QR token bulunamadı.',
        );
      }

      final ticketRef = ref;

      final txSuccess = await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(ticketRef);
        if (!snapshot.exists) return false;

        final data = snapshot.data() as Map<String, dynamic>;
        final alreadyScanned = data['isScanned'] == true;
        final status = data['status']?.toString().toLowerCase() ?? '';
        final tourId = data['tourId']?.toString() ?? '';
        final tokenInDb = data['qrToken']?.toString() ?? '';
        final normalizedInDb = _normalizeQrToken(tokenInDb);

        if (tourId.trim() != expectedTourId.trim()) {
          debugPrint(
            'consumeTicketByQrToken: Tur eşleşmedi. ticketTourId=$tourId expectedTourId=$expectedTourId',
          );
          return false;
        }
        if (normalizedInDb != normalizedToken) {
          debugPrint('consumeTicketByQrToken: DB token uyuşmadı');
          return false;
        }
        if (alreadyScanned || status == 'cancelled' || status == 'completed') {
          debugPrint(
            'consumeTicketByQrToken: Bilet artık geçersiz. alreadyScanned=$alreadyScanned status=$status',
          );
          return false;
        }

        tx.update(ticketRef, {
          'isScanned': true,
          'status': 'checked_in',
          'scannedAt': FieldValue.serverTimestamp(),
          'qrToken': null,
        });

        return true;
      });

      if (txSuccess) {
        return const QrConsumeResult(success: true, code: 'ok', message: 'QR doğrulandı.');
      }

      return const QrConsumeResult(
        success: false,
        code: 'invalid_or_used',
        message: 'QR geçersiz, farklı tura ait veya daha önce kullanılmış.',
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('consumeTicketByQrToken: permission-denied, no-read fallback deneniyor');
        return _consumeTicketByPayloadNoRead(
          ticketId: payloadTicketId,
          payloadTourId: payloadTourId,
          expectedTourId: expectedTourId,
        );
      }

      debugPrint('QR Token Consume FirebaseError: ${e.code} ${e.message}');
      return QrConsumeResult(
        success: false,
        code: e.code,
        message: 'Firebase hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('QR Token Consume Error: $e');
      return QrConsumeResult(
        success: false,
        code: 'unknown_error',
        message: 'Beklenmeyen hata: $e',
      );
    }
  }

  Future<QrConsumeResult> _consumeTicketByPayloadNoRead({
    required String ticketId,
    required String payloadTourId,
    required String expectedTourId,
  }) async {
    try {
      if (ticketId.trim().isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'ticket_id_missing',
          message: 'QR içinde ticketId bulunamadı.',
        );
      }
      if (payloadTourId.trim().isNotEmpty && payloadTourId.trim() != expectedTourId.trim()) {
        return const QrConsumeResult(
          success: false,
          code: 'tour_mismatch_payload',
          message: 'QR farklı tura ait görünüyor.',
        );
      }

      await _firestore.collection('tickets').doc(ticketId).update({
        'isScanned': true,
        'status': 'checked_in',
        'scannedAt': FieldValue.serverTimestamp(),
        'qrToken': null,
      });

      return const QrConsumeResult(
        success: true,
        code: 'ok_no_read_fallback',
        message: 'QR doğrulandı (fallback).',
      );
    } on FirebaseException catch (e) {
      debugPrint('no-read fallback failed: ${e.code} ${e.message}');
      return QrConsumeResult(
        success: false,
        code: 'fallback_${e.code}',
        message: 'Fallback hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('no-read fallback error: $e');
      return QrConsumeResult(
        success: false,
        code: 'fallback_unknown_error',
        message: 'Fallback beklenmeyen hata: $e',
      );
    }
  }

  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Ticket Status Update Error: $e');
      return false;
    }
  }

  // ==================== CHAT & ANNOUNCEMENT ====================
  // Mesaj gönderimi (Sadece tourId ve ChatModel alır)
  Future<void> sendChatMessage(String tourId, ChatModel message) async {
    debugPrint('═══ SEND_MSG: Başladı ═══');
    debugPrint('SEND_MSG: tourId=$tourId');
    debugPrint('SEND_MSG: senderId=${message.senderId}');
    debugPrint('SEND_MSG: senderName=${message.senderName}');
    debugPrint('SEND_MSG: text=${message.text}');

    final ref = _firestore.collection('tours').doc(tourId).collection('messages');
    debugPrint('SEND_MSG: Yazılıyor → ${ref.path}');

    final docRef = await ref.add(message.toJson());
    debugPrint('SEND_MSG: BAŞARILI ✓ docId=${docRef.id}');
    debugPrint('═══ SEND_MSG: Tamamlandı ═══');
  }

  // Mesajları dinle (Stream)
  Stream<List<ChatModel>> getChatMessages(String tourId) {
    debugPrint('getChatMessages: Stream başlatılıyor → tours/$tourId/messages');
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          debugPrint('getChatMessages: snapshot → ${snapshot.docs.length} mesaj');
          return snapshot.docs.map(ChatModel.fromFirestore).toList();
        });
  }

  // Tüm mesajları getir (olmayan fonksiyon için) [cite: 6]
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
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  // Mesaj sil [cite: 6]
  Future<void> deleteChatMessage(String tourId, String messageId) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  // Duyuru oluşturma
  Future<void> createAnnouncement(String tourId, AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .add(announcement.toJson());
    } catch (e) {
      debugPrint('Announcement Error: $e');
      throw Exception('Duyuru kaydedilemedi: $e');
    }
  }

  // Duyuruları dinle (Stream)
  Stream<List<AnnouncementModel>> getAnnouncements(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(AnnouncementModel.fromFirestore).toList();
        });
  }

  // Customer için fallback: kendi bildirimlerinden tur duyurularını dinle
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

  // Tüm duyuruları getir [cite: 25]
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
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  // Duyuru sil [cite: 25]
  Future<void> deleteAnnouncement(String tourId, String announcementId) async {
    try {
      await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .doc(announcementId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
    }
  }

  // Tur katılımcılarına bildirim gönder [cite: 21, 25]
  Future<void> sendNotificationToTourParticipants(String tourId, String message) async {
    try {
      // QR okutan katılımcı biletlerini al
      final tickets = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('isScanned', isEqualTo: true)
          .get();

      final uniqueUserIds = <String>{};
      for (final doc in tickets.docs) {
        final rawUserId = doc.data()['userId'];
        final userId = rawUserId?.toString().trim() ?? '';
        if (userId.isNotEmpty) {
          uniqueUserIds.add(userId);
        }
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
      debugPrint('Error sending notification: $e');
      throw Exception('Katılımcı bildirimleri kaydedilemedi: $e');
    }
  }

  // ==================== AUTH & AUTHORIZATION ====================
  // Kayıt ol - Mobile App'te sadece customer role'ü olabilir [cite: 12, 40]
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;

      final newUser = UserModel(
        uid: userId,
        fullName: '$name $surname',
        email: email,
        phone: '',
        role: 'customer', // Mobile App'te sadece customer olabilir
        companyId: '',
        registeredCompanies: [],
        tcNo: '',
        selectedCity: '',
        profileImage: null,
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toJson());
      return newUser;
    } catch (e) {
      debugPrint('Registration Error: $e');
      throw Exception("Kayıt başarısız: ${e.toString()}");
    }
  }

  // Çıkış yap [cite: 12]
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout Error: $e');
      throw Exception("Çıkış başarısız");
    }
  }

  // Şifre sıfırla [cite: 12]
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      throw Exception("Şifre sıfırlama hatası");
    }
  }

  // SaaS Yetki Kontrolü
  Future<bool> isAuthorizedForCompany(String userId, String companyId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final user = UserModel.fromFirestore(userDoc);
    if (user.role == 'super_admin') return true;
    return user.registeredCompanies.contains(companyId);
  }

  // Giriş ve Yetki Kontrolü
  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = cred.user!.uid;

    final doc = await _firestore.collection('users').doc(userId).get();
    final user = UserModel.fromFirestore(doc);

    // Mobile App'te SADECE customer, guest, guide olabilir
    // Admin/Super Admin web panel'de (ayrı proje) [cite: 40, 42]
    if (user.role == 'admin' || user.role == 'super_admin') {
      await _auth.signOut();
      throw Exception(
        "Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.",
      );
    }

    return user;
  }

  // Şu anki kullanıcının ID'sini getir
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  // ==================== GUIDE/TUR SORUMLUSU GIRIŞI ====================
  // Tur Sorumlusu Girişi - Web Admin Panel'de oluşturulan ID/PW ile [cite: 18, 21]
  // Web Admin Panel'de şirket admin'i tur sorumlusuna ID/PW oluşturur
  // Mobile App'te tur sorumlusu sadece giriş yapıyor
  Future<UserModel?> guideLogin(String guideId, String password) async {
    try {
      // Web Admin Panel'de oluşturulan guide record'ı getir
      final doc = await _firestore.collection('guides').doc(guideId).get();

      if (!doc.exists) {
        throw Exception("Tur sorumlusu bulunamadı");
      }

      final data = doc.data() as Map<String, dynamic>;
      final storedPassword = data['password'] as String;

      // Şifre kontrolü
      if (storedPassword != password) {
        throw Exception("Şifre yanlış");
      }

      final fullName = data['fullName']?.toString() ?? 'Tur Sorumlusu';
      final email = data['email']?.toString() ?? '';
      final phone = data['phone']?.toString() ?? '';
      final companyId = data['companyId']?.toString() ?? '';
      final isDeleted = data['isDeleted'] == true;

      return UserModel(
        uid: doc.id,
        fullName: fullName,
        email: email,
        phone: phone,
        role: 'guide',
        companyId: companyId,
        registeredCompanies: List<String>.from(
          (data['registeredCompanies'] as List?) ?? [if (companyId.trim().isNotEmpty) companyId],
        ),
        tcNo: data['tcNo']?.toString() ?? '',
        selectedCity: data['selectedCity']?.toString() ?? '',
        profileImage: data['profileImage']?.toString(),
        isDeleted: isDeleted,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Guide Login Error: $e');
      throw Exception(e.toString());
    }
  }
}
