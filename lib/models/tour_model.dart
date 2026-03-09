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
  final String? companyName;
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

  /// Tekil tur tarihi (opsiyonel, eski tek tarih alanı)
  final DateTime? departureDate;

  /// Özel çıkış tarihleri listesi. Bu tarihler turun altında slot olarak kullanılır.
  final List<DateTime>? departureDates;

  /// Aynı turun farklı tarihlere ait instance'larını gruplamak için.
  /// Aynı seriesId'ye sahip turlar UI'da tek kart olarak gösterilir.
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

  // ── Türkiye (UTC+3) saat dilimi yardımcıları ──
  // Türkiye 2016'dan beri kalıcı UTC+3 kullanır (DST yok).
  // Cihaz saat diliminden bağımsız olarak her zaman doğru tarih verir.

  /// Firestore Timestamp → Türkiye tarihine çevir.
  static DateTime _tsToTurkeyDate(Timestamp ts) {
    final utc = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch, isUtc: true);
    final turkey = utc.add(const Duration(hours: 3));
    return DateTime(turkey.year, turkey.month, turkey.day);
  }

  /// Türkiye tarihini Firestore Timestamp'e çevir (gece yarısı UTC+3).
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
      capacity: data['capacity'] ?? 0,
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      busInfo: BusInfo.fromMap(data['busInfo'] ?? {}),
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
        return list.whereType<Timestamp>().map((ts) => _tsToTurkeyDate(ts)).toList();
      }(),
      seriesId: data['seriesId']?.toString(),
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
      'departureDates': departureDates?.map((d) => _turkeyDateToTs(d)).toList(),
      'seriesId': seriesId,
    };
  }

  /// Yakın [count] çıkış tarihini hesaplar.
  /// departureDays (haftalık) + departureDates (özel tarihler) birleştirilir.
  List<DateTime> getUpcomingDepartures({int count = 8}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final seen = <String>{};
    final result = <DateTime>[];

    void addIfUnique(DateTime d) {
      if (d.isBefore(today)) return;
      final key = '${d.year}-${d.month}-${d.day}';
      if (seen.contains(key)) return;
      seen.add(key);
      result.add(DateTime(d.year, d.month, d.day));
    }

    // 1. Özel tarihler (departureDates) — zaten Türkiye tarihine çevrilmiş
    for (final d in departureDates ?? []) {
      if (result.length >= count) break;
      addIfUnique(d);
    }

    // 2. Haftalık günlerden türetilen tarihler (departureDays)
    if (departureDays.isNotEmpty) {
      for (var i = 0; i < 60 && result.length < count; i++) {
        final d = today.add(Duration(days: i));
        if (departureDays.contains(d.weekday)) {
          addIfUnique(d);
        }
      }
    }

    result.sort((a, b) => a.compareTo(b));
    return result.take(count).toList();
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
