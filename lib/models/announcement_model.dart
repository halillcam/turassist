import 'package:cloud_firestore/cloud_firestore.dart';

/// Rehberin kendi turuna ait katılımcılara gönderdiği duyuruyu temsil eder.
///
/// `tours/{tourId}/announcements` koleksiyonunda saklanır.
/// Müşteri tarafında fallback olarak `/users/{uid}/notifications`
/// koleksiyonundan da okunabilir.
class AnnouncementModel {
  final String id;

  /// Duyuru metni; Firestore'daki alan adı `notification`'dır.
  final String notification;

  final DateTime createdAt;

  AnnouncementModel({required this.id, required this.notification, required this.createdAt});

  /// Firestore belgesinden [AnnouncementModel] oluşturur.
  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      notification: data['notification'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'a yazılmak üzere JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {'notification': notification, 'createdAt': Timestamp.fromDate(createdAt)};
  }
}
