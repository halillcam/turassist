import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String notification; // Firestore'daki alan adı
  final DateTime createdAt;

  AnnouncementModel({required this.id, required this.notification, required this.createdAt});

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      notification: data['notification'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'notification': notification, 'createdAt': Timestamp.fromDate(createdAt)};
  }
}
