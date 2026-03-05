import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir turun günlüklere ayrılmış programındaki tek günü temsil eder.
///
/// `tours/{tourId}/program` koleksiyonunda saklanır.
/// `order` alanına göre sıralanır.
class TourProgramDay {
  final String id;

  /// Günün başlığı ("1. Gün: İstanbul").
  final String title;

  /// Program gün numarası (1-bazlı).
  final int day;

  /// Listede gösterilecek sıra (düşük = önce).
  final int order;

  /// O gün yapılacak aktivitelerin listesi.
  final List<String> activities;

  TourProgramDay({
    required this.id,
    required this.title,
    required this.day,
    required this.order,
    required this.activities,
  });

  /// Firestore belgesinden [TourProgramDay] oluşturur.
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
