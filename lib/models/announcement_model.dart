import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String tourId;
  final String guideId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isUrgent;

  AnnouncementModel({
    required this.id,
    required this.tourId,
    required this.guideId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isUrgent,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      tourId: data['tourId'] ?? '',
      guideId: data['guideId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isUrgent: data['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tourId': tourId,
      'guideId': guideId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'isUrgent': isUrgent,
    };
  }
}
