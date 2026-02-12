import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/announcement_model.dart';

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

      return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching tours: $e");
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

      return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
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
      print("Error fetching cities: $e");
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
      print("Error fetching tour: $e");
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

      return snapshot.docs.map((doc) => TourProgramDay.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching tour program: $e");
      return [];
    }
  }

  // Turu güncelle [cite: 32]
  Future<void> updateTour(String tourId, TourModel tour) async {
    try {
      await _firestore.collection('tours').doc(tourId).update(tour.toJson());
    } catch (e) {
      print("Error updating tour: $e");
    }
  }

  // Tur katılımcılarını getir [cite: 21, 32]
  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('status', isNotEqualTo: 'cancelled')
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print("Error fetching tour participants: $e");
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
      print("Error finishing tour: $e");
    }
  }

  // ==================== TICKET & QR OPERATIONS ====================
  // Bilet oluşturma [cite: 15, 28]
  Future<String> createTicket(TicketModel ticket) async {
    try {
      final docRef = _firestore.collection('tickets').doc();
      await docRef.set(ticket.toJson());
      return docRef.id;
    } catch (e) {
      print("Error creating ticket: $e");
      throw Exception("Bilet oluşturma başarısız");
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
      print("getUserProfile Error: $e");
      return null;
    }
  }

  // Kullanıcının biletlerini getir [cite: 15]
  Future<List<TicketModel>> getUserTickets() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception("Kullanıcı giriş yapmamış");

      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching user tickets: $e");
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
      print("QR Token Generation Error: $e");
      throw Exception("QR token oluşturulamadı");
    }
  }

  // QR Token'ı Bilete Kaydet [cite: 18, 32]
  Future<void> updateTicketQRToken(String ticketId, String qrToken) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'qrToken': qrToken});
    } catch (e) {
      print("QR Token Update Error: $e");
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
      print("QR Scan Error: $e");
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
      print("Ticket Status Update Error: $e");
      return false;
    }
  }

  // ==================== CHAT & ANNOUNCEMENT ====================
  // Mesaj gönderimi (Sadece tourId ve ChatModel alır)
  Future<void> sendChatMessage(String tourId, ChatModel message) async {
    try {
      await _firestore.collection('tours').doc(tourId).collection('messages').add(message.toJson());
    } catch (e) {
      print("Chat Error: $e");
    }
  }

  // Mesajları dinle (Stream)
  Stream<List<ChatModel>> getChatMessages(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
        });
  }

  // Tüm mesajları getir (olmayan fonksiyon için) [cite: 6]
  Future<List<ChatModel>> getAllChatMessages(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching chat messages: $e");
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
      print("Error deleting message: $e");
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
      print("Announcement Error: $e");
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
          return snapshot.docs.map((doc) => AnnouncementModel.fromFirestore(doc)).toList();
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

      return snapshot.docs.map((doc) => AnnouncementModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching announcements: $e");
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
      print("Error deleting announcement: $e");
    }
  }

  // Tur katılımcılarına bildirim gönder [cite: 21, 25]
  Future<void> sendNotificationToTourParticipants(String tourId, String message) async {
    try {
      // Tüm katılımcı bileti al
      final tickets = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('isScanned', isEqualTo: true)
          .get();

      // Her katılımcıya bildirim kaydı oluştur
      for (var doc in tickets.docs) {
        final userId = doc['userId'];
        await _firestore.collection('users').doc(userId).collection('notifications').add({
          'title': 'Tur Bildirim',
          'message': message,
          'tourId': tourId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      print("Error sending notification: $e");
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
      print("Registration Error: $e");
      throw Exception("Kayıt başarısız: ${e.toString()}");
    }
  }

  // Çıkış yap [cite: 12]
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
      throw Exception("Çıkış başarısız");
    }
  }

  // Şifre sıfırla [cite: 12]
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Password Reset Error: $e");
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

    final authorized = await isAuthorizedForCompany(userId, companyId);
    if (!authorized) {
      await _auth.signOut();
      throw Exception("Bu şirket paneline giriş yetkiniz yok.");
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
      print("Guide Login Error: $e");
      throw Exception(e.toString());
    }
  }
}
