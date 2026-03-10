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
    return TourProgramDay.fromMap(data, id: doc.id);
  }

  factory TourProgramDay.fromMap(Map<String, dynamic> data, {String id = ''}) {
    final rawActivities = data['activities'] ?? data['items'] ?? data['programItems'] ?? const [];
    final activities = _parseActivities(rawActivities);
    final rawDay = data['day'] ?? data['dayNumber'] ?? data['index'] ?? 0;
    final rawOrder = data['order'] ?? data['sortOrder'] ?? rawDay;
    final resolvedDay = rawDay is num ? rawDay.toInt() : int.tryParse(rawDay.toString()) ?? 0;
    final resolvedOrder = rawOrder is num
        ? rawOrder.toInt()
        : int.tryParse(rawOrder.toString()) ?? 0;
    final resolvedTitle = (data['title'] ?? data['name'] ?? data['heading'] ?? '')
        .toString()
        .trim();

    return TourProgramDay(
      id: id,
      title: resolvedTitle.isEmpty ? 'Gün ${resolvedDay == 0 ? 1 : resolvedDay}' : resolvedTitle,
      day: resolvedDay,
      order: resolvedOrder,
      activities: activities,
    );
  }

  static List<String> _parseActivities(dynamic rawActivities) {
    if (rawActivities is List) {
      return rawActivities
          .map((item) {
            if (item is String) {
              return item.trim();
            }
            if (item is Map<String, dynamic>) {
              return (item['title'] ?? item['name'] ?? item['description'] ?? item['text'] ?? '')
                  .toString()
                  .trim();
            }
            if (item is Map) {
              return (item['title'] ?? item['name'] ?? item['description'] ?? item['text'] ?? '')
                  .toString()
                  .trim();
            }
            return item.toString().trim();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (rawActivities is String && rawActivities.trim().isNotEmpty) {
      return [rawActivities.trim()];
    }

    return const [];
  }
}
