import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement_model.dart';
import '../models/chat_model.dart';
import '../models/ticket_model.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      final all = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      return all.where((item) {
        final status = item['status']?.toString().toLowerCase() ?? '';
        return status != 'cancelled';
      }).toList();
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
  Future<String> createTicket(TicketModel ticket) async {
    try {
      debugPrint('createTicket: userId=${ticket.userId}, tourId=${ticket.tourId}');
      debugPrint('createTicket: toJson=${ticket.toJson()}');
      final docRef = _firestore.collection('tickets').doc();
      await docRef.set(ticket.toJson());
      debugPrint('createTicket: BAŞARILI → docId=${docRef.id}');
      return docRef.id;
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
  Future<String> generateQRToken(String ticketId) async {
    try {
      // Kombinasyon: ticketId + timestamp + random string
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPart = DateTime.now().microsecond.toString();
      final qrToken = '$ticketId-$timestamp-$randomPart';

      return qrToken;
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
    }
  }

  // Rehberin QR okutma işlemi (Security Rules uyumlu: isScanned & scannedAt)
  Future<bool> updateTicketQRStatus(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'isScanned': true,
        'status': 'checked_in',
        'scannedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('QR Scan Error: $e');
      return false;
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

      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Guide Login Error: $e');
      throw Exception(e.toString());
    }
  }
}
