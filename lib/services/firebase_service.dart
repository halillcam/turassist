import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/models/ticket_model.dart';
import 'package:turassist/models/user_model.dart';
import 'package:turassist/models/company_model.dart';
import 'package:turassist/models/chat_model.dart';
import 'package:turassist/models/announcement_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== TOUR OPERATIONS ====================
  Future<List<TourModel>> getToursByCity(String city) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('departureCity', isEqualTo: city)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<TourModel?> getTourById(String tourId) async {
    try {
      final snapshot = await _firestore.collection('tours').doc(tourId).get();
      if (snapshot.exists) {
        return TourModel.fromFirestore(snapshot);
      }
    } catch (e) {
      // Error getting tour
    }
    return null;
  }

  Future<List<String>> getServiceCities() async {
    try {
      final snapshot = await _firestore.collection('companies').get();
      final Set<String> cities = {};

      for (var doc in snapshot.docs) {
        final company = CompanyModel.fromFirestore(doc);
        cities.addAll(company.serviceCities);
      }

      return cities.toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== TICKET OPERATIONS ====================
  Future<String?> createTicket(TicketModel ticket) async {
    try {
      final docRef = await _firestore.collection('tickets').add(ticket.toMap());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TicketModel>> getTourTickets(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('qrScanned', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => TicketModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateTicketQRStatus(String ticketId, String qrCode, bool scanned) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'qrCode': qrCode,
        'qrScanned': scanned,
        'scanDate': DateTime.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== CHAT OPERATIONS ====================
  Future<void> sendChatMessage(ChatMessage message) async {
    try {
      await _firestore
          .collection('tours')
          .doc(message.tourId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      // Error sending message
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
        });
  }

  // ==================== ANNOUNCEMENT OPERATIONS ====================
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection('tours')
          .doc(announcement.tourId)
          .collection('announcements')
          .add(announcement.toMap());
    } catch (e) {
      // Error creating announcement
    }
  }

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

  // ==================== USER OPERATIONS ====================
  Future<UserModel?> getUserById(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
    } catch (e) {
      // Error getting user
    }
    return null;
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== COMPANY OPERATIONS ====================
  Future<CompanyModel?> getCompanyById(String companyId) async {
    try {
      final snapshot = await _firestore.collection('companies').doc(companyId).get();
      if (snapshot.exists) {
        return CompanyModel.fromFirestore(snapshot);
      }
    } catch (e) {
      // Error getting company
    }
    return null;
  }
}
