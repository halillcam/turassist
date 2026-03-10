import 'package:cloud_firestore/cloud_firestore.dart';

class BusInfo {
  final String driverName;
  final String phoneNumber;
  final String plate;
  final int capacity;

  BusInfo({
    required this.driverName,
    required this.phoneNumber,
    required this.plate,
    required this.capacity,
  });

  factory BusInfo.fromMap(Map<String, dynamic> map) {
    return BusInfo(
      driverName: map['driverName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      plate: map['plate'] ?? '',
      capacity: _readInt(map['capacity']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'driverName': driverName,
      'phoneNumber': phoneNumber,
      'plate': plate,
      'capacity': capacity,
    };
  }
}

class TourModel {
  final String id;
  final String title;
  final String description;
  final String extraDetail;
  final double price;
  final String imageUrl;
  final String companyId;
  final String? companyName;
  final String guideId;
  final String? guideName;
  final int capacity;
  final String city;
  final String region;
  final BusInfo busInfo;
  final DateTime createdAt;
  final bool isDeleted;
  final List<int> departureDays;
  final String departureTime;
  final DateTime? departureDate;
  final List<DateTime>? departureDates;
  final String? seriesId;

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.extraDetail,
    required this.price,
    required this.imageUrl,
    required this.companyId,
    this.companyName,
    required this.guideId,
    this.guideName,
    required this.capacity,
    required this.city,
    required this.region,
    required this.busInfo,
    required this.createdAt,
    required this.isDeleted,
    this.departureDays = const [],
    this.departureTime = '',
    this.departureDate,
    this.departureDates,
    this.seriesId,
  });

  static DateTime _tsToTurkeyDate(Timestamp ts) {
    final utc = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch, isUtc: true);
    final turkey = utc.add(const Duration(hours: 3));
    return DateTime(turkey.year, turkey.month, turkey.day);
  }

  static Timestamp _turkeyDateToTs(DateTime date) {
    final utcMidnightTurkey = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).subtract(const Duration(hours: 3));
    return Timestamp.fromMillisecondsSinceEpoch(utcMidnightTurkey.millisecondsSinceEpoch);
  }

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final busInfoMap = Map<String, dynamic>.from(data['busInfo'] ?? const {});
    final parsedBusInfo = BusInfo.fromMap(busInfoMap);
    final resolvedCapacity = _readCapacity(data, parsedBusInfo.capacity);

    return TourModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      extraDetail: data['extraDetail'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      companyId: data['companyId'] ?? '',
      companyName: data['companyName']?.toString(),
      guideId: data['guideId'] ?? '',
      guideName: data['guideName'],
      capacity: resolvedCapacity,
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      busInfo: parsedBusInfo,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
      departureDays:
          (data['departureDays'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
      departureTime: data['departureTime'] ?? '',
      departureDate: data['departureDate'] is Timestamp
          ? _tsToTurkeyDate(data['departureDate'] as Timestamp)
          : null,
      departureDates: () {
        final raw = data['departureDates'];
        if (raw == null) return null;
        final list = raw as List<dynamic>?;
        if (list == null || list.isEmpty) return null;
        return list.whereType<Timestamp>().map(_tsToTurkeyDate).toList();
      }(),
      seriesId: data['seriesId']?.toString(),
    );
  }

  static int _readCapacity(Map<String, dynamic> data, int busCapacity) {
    final rawCapacity = data['capacity'];
    if (rawCapacity is num) return rawCapacity.toInt();

    final parsedTopLevel = int.tryParse(rawCapacity?.toString() ?? '');
    if (parsedTopLevel != null) return parsedTopLevel;

    return busCapacity;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'extraDetail': extraDetail,
      'price': price,
      'imageUrl': imageUrl,
      'companyId': companyId,
      'companyName': companyName,
      'guideId': guideId,
      'guideName': guideName,
      'capacity': capacity,
      'city': city,
      'region': region,
      'busInfo': busInfo.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
      'departureDays': departureDays,
      'departureTime': departureTime,
      'departureDate': departureDate != null ? _turkeyDateToTs(departureDate!) : null,
      'departureDates': departureDates?.map(_turkeyDateToTs).toList(),
      'seriesId': seriesId,
    };
  }

  List<DateTime> getUpcomingDepartures({int count = 8}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final seen = <String>{};
    final result = <DateTime>[];

    void addIfUnique(DateTime date) {
      if (date.isBefore(today)) return;
      final key = '${date.year}-${date.month}-${date.day}';
      if (seen.contains(key)) return;
      seen.add(key);
      result.add(DateTime(date.year, date.month, date.day));
    }

    for (final date in departureDates ?? []) {
      if (result.length >= count) break;
      addIfUnique(date);
    }

    if (departureDays.isNotEmpty) {
      for (var index = 0; index < 60 && result.length < count; index++) {
        final date = today.add(Duration(days: index));
        if (departureDays.contains(date.weekday)) {
          addIfUnique(date);
        }
      }
    }

    result.sort((left, right) => left.compareTo(right));
    return result.take(count).toList();
  }

  bool get isDepartureToday => departureDays.contains(DateTime.now().weekday);

  String get departureDaysText {
    if (departureDays.isEmpty) return 'Takvim yok';
    const dayNames = {1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'};
    final sorted = List<int>.from(departureDays)..sort();
    return sorted.map((day) => dayNames[day] ?? '?').join(', ');
  }
}
