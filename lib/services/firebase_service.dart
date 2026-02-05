import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';
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

  // ==================== TICKET & QR OPERATIONS ====================
  // Bilet oluşturma
  Future<String?> createTicket(TicketModel ticket) async {
    try {
      final docRef = _firestore.collection('tickets').doc();
      await docRef.set(ticket.toJson());
      return docRef.id;
    } catch (e) {
      return null;
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

  // ==================== AUTH & AUTHORIZATION ====================
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

    final authorized = await isAuthorizedForCompany(userId, companyId);
    if (!authorized) {
      await _auth.signOut();
      throw Exception("Bu şirket paneline giriş yetkiniz yok.");
    }

    final doc = await _firestore.collection('users').doc(userId).get();
    return UserModel.fromFirestore(doc);
  }
}
