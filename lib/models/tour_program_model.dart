import 'package:cloud_firestore/cloud_firestore.dart';

class TourProgramDay {
  final String id;
  final String title;
  final int day;
  final int order;
  final List<String> activities;

  TourProgramDay({
    required this.id,
    required this.title,
    required this.day,
    required this.order,
    required this.activities,
  });

  factory TourProgramDay.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourProgramDay(
      id: doc.id,
      title: data['title'] ?? '',
      day: data['day'] ?? 0,
      order: data['order'] ?? 0,
      activities: List<String>.from(data['activities'] ?? []),
    );
  }
}
