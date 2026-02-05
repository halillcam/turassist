import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../models/company_model.dart';
import '../models/chat_model.dart';
import '../models/announcement_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== TOUR OPERATIONS ====================

  Future<List<TourModel>> getActiveTours() async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getActiveTours: $e');
      return [];
    }
  }

  Future<List<TourModel>> getToursByCity(String city) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('isDeleted', isEqualTo: false)
          .where('city', isEqualTo: city)
          .get();

      return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getToursByCity: $e');
      return [];
    }
  }

  // ==================== TOUR OPERATIONS EKLER ====================

  Future<List<String>> getServiceCities() async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('isDeleted', isEqualTo: false)
          .get();

      final cities = snapshot.docs
          .map((d) => (d.data()['city'] ?? '') as String)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      return cities;
    } catch (e) {
      print('Error getServiceCities: $e');
      return [];
    }
  }

  Stream<List<TourModel>> publicToursByCompany(String companyId) {
    return _firestore
        .collection('tours')
        .where('companyId', isEqualTo: companyId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TourModel.fromFirestore(doc)).toList());
  }

  // ==================== TICKET & QR OPERATIONS ====================

  Future<String?> createTicket(TicketModel ticket) async {
    try {
      // BookingController.checkAccessForTour ile uyumlu ID
      final ticketId = '${ticket.userId}_${ticket.tourId}';
      final docRef = _firestore.collection('tickets').doc(ticketId);

      final data = ticket.toJson();
      data['id'] = ticketId;

      await docRef.set(data);
      return ticketId;
    } catch (e) {
      print('Error createTicket: $e');
      return null;
    }
  }

  Future<bool> updateTicketQRStatus(String ticketId) async {
    try {
      final docRef = _firestore.collection('tickets').doc(ticketId);
      final snap = await docRef.get();
      if (!snap.exists) return false;

      await docRef.update({
        'isScanned': true,
        'status': 'checked_in',
        'scannedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updateTicketQRStatus: $e');
      return false;
    }
  }

  Future<TourModel?> getTourById(String tourId) async {
    try {
      final doc = await _firestore.collection('tours').doc(tourId).get();
      if (!doc.exists) return null;
      return TourModel.fromFirestore(doc);
    } catch (e) {
      print('Error getTourById: $e');
      return null;
    }
  }

  Future<List<TicketModel>> getTourTickets(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .get();

      return snapshot.docs.map((d) => TicketModel.fromFirestore(d)).toList();
    } catch (e) {
      print('Error getTourTickets: $e');
      return [];
    }
  }

  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((d) => TicketModel.fromFirestore(d)).toList();
    } catch (e) {
      print('Error getUserTickets: $e');
      return [];
    }
  }

  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection('tickets').doc(ticketId).get();
      if (!doc.exists) return null;
      return TicketModel.fromFirestore(doc);
    } catch (e) {
      print('Error getTicketById: $e');
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updateUser: $e');
    }
  }

  // ==================== CHAT & ANNOUNCEMENT ====================

  Future<void> sendChatMessage(String tourId, ChatModel message) async {
    try {
      await _firestore.collection('tours').doc(tourId).collection('messages').add(message.toJson());
    } catch (e) {
      print('Error sendChatMessage: $e');
    }
  }

  Future<void> createAnnouncement(String tourId, AnnouncementModel announcement) async {
    try {
      final colRef = _firestore.collection('tours').doc(tourId).collection('announcements');
      final docRef = colRef.doc();
      final data = announcement.toJson();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      print('Error createAnnouncement: $e');
    }
  }

  Stream<List<ChatModel>> getChatMessages(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatModel.fromFirestore(d)).toList());
  }

  Stream<List<AnnouncementModel>> getAnnouncements(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AnnouncementModel.fromFirestore(d)).toList());
  }

  // ==================== AUTH & AUTHORIZATION ====================

  Future<bool> isAuthorizedForCompany(String userId, String companyId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    final data = userDoc.data()!;
    final single = data['companyId'] as String?;
    final list = (data['companyIds'] as List?)?.cast<String>() ?? <String>[];
    return single == companyId || list.contains(companyId);
  }

  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return null;

      final allowed = await isAuthorizedForCompany(user.uid, companyId);
      if (!allowed) {
        await _auth.signOut();
        throw Exception('Bu firmaya erişim yetkiniz yok');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      print('Error loginAndCheckAuth: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithCompanyAuthorization({
    required String email,
    required String password,
    required String companyId,
  }) {
    return loginAndCheckAuth(email, password, companyId);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
