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
      capacity: map['capacity'] ?? 0,
    );
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
  final String guideId;
  final String? guideName;
  final int capacity;
  final String city;
  final String region;
  final BusInfo busInfo;
  final DateTime createdAt;
  final bool isDeleted;

  /// Haftalık çıkış günleri (1=Pazartesi … 7=Pazar).
  /// Örn: [1] = Her Pazartesi, [1,4] = Pazartesi+Perşembe.
  /// Boş liste = takvim ayarlanmamış (eski turlarla uyum).
  final List<int> departureDays;

  /// Çıkış saati, örn: "09:00".
  final String departureTime;

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.extraDetail,
    required this.price,
    required this.imageUrl,
    required this.companyId,
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
  });

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      extraDetail: data['extraDetail'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      companyId: data['companyId'] ?? '',
      guideId: data['guideId'] ?? '',
      guideName: data['guideName'],
      capacity: data['capacity'] ?? 0,
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      busInfo: BusInfo.fromMap(data['busInfo'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
      departureDays:
          (data['departureDays'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
      departureTime: data['departureTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'extraDetail': extraDetail,
      'price': price,
      'imageUrl': imageUrl,
      'companyId': companyId,
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
    };
  }

  /// Yakın [count] çıkış tarihini hesaplar.
  /// [departureDays] boşsa boş liste döner.
  List<DateTime> getUpcomingDepartures({int count = 8}) {
    if (departureDays.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime>[];
    var cursor = today;

    // En fazla 60 gün ileri bak, istenen sayıya ulaşınca dur
    for (var i = 0; i < 60 && result.length < count; i++) {
      final d = cursor.add(Duration(days: i));
      // DateTime.weekday: 1=Monday … 7=Sunday
      if (departureDays.contains(d.weekday)) {
        result.add(d);
      }
    }
    return result;
  }

  /// Bugün çıkış günü mü?
  bool get isDepartureToday => departureDays.contains(DateTime.now().weekday);

  /// Çıkış günlerinin Türkçe kısa isimleri.
  String get departureDaysText {
    if (departureDays.isEmpty) return 'Takvim yok';
    const dayNames = {1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'};
    final sorted = List<int>.from(departureDays)..sort();
    return sorted.map((d) => dayNames[d] ?? '?').join(', ');
  }
}
