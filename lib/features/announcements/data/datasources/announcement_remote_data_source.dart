import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/announcement_model.dart';

class AnnouncementRemoteDataSource {
  AnnouncementRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Stream<List<AnnouncementModel>> watchTourAnnouncements(String tourId) {
    return _firestore
        .collection('tours')
        .doc(tourId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AnnouncementModel.fromAnnouncementDoc).toList());
  }

  Stream<List<AnnouncementModel>> watchUserAnnouncements(String userId, String tourId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('tourId', isEqualTo: tourId)
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs.map(AnnouncementModel.fromNotificationDoc).toList();
          announcements.sort((left, right) => right.createdAt.compareTo(left.createdAt));
          return announcements;
        });
  }

  Future<String> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid ?? '';
  }

  Future<({String role, String fullName})> getCurrentSenderProfile() async {
    final userId = _firebaseAuth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('Oturum bulunamadı.');
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('Kullanıcı profili bulunamadı.');
    }

    final data = userDoc.data() ?? <String, dynamic>{};
    return (
      role: data['role']?.toString().trim().toLowerCase() ?? '',
      fullName: data['fullName']?.toString().trim() ?? 'Tur Sorumlusu',
    );
  }

  Future<void> sendAnnouncementToCheckedInParticipants({
    required String tourId,
    required String message,
  }) async {
    final sender = await getCurrentSenderProfile();
    if (sender.role != 'guide') {
      throw Exception('Duyuru sadece tur sorumlusu tarafından gönderilebilir.');
    }
    final announcementRef = _firestore
        .collection('tours')
        .doc(tourId)
        .collection('announcements')
        .doc();

    final announcement = AnnouncementModel(
      id: announcementRef.id,
      message: message,
      createdAt: DateTime.now(),
      scope: 'checked_in_only',
      senderRole: sender.role,
      senderName: sender.fullName,
    );

    await announcementRef.set(announcement.toAnnouncementJson());
  }
}
