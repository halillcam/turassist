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
  final double price;
  final String imageUrl; // Eksik olan görsel alanı eklendi
  final String companyId;
  final String guideId;
  final String? guideName;
  final int capacity;
  final String city; // departure/destination yerine tek city
  final String region; // Türkiye bölgesi (Karadeniz, Ege, vb.)
  final BusInfo busInfo;
  final DateTime createdAt;
  final bool isDeleted; // isActive yerine isDeleted

  TourModel({
    required this.id,
    required this.title,
    required this.description,
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
  });

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '', //
      companyId: data['companyId'] ?? '',
      guideId: data['guideId'] ?? '',
      guideName: data['guideName'],
      capacity: data['capacity'] ?? 0,
      city: data['city'] ?? '',
      region: data['region'] ?? '',
      busInfo: BusInfo.fromMap(data['busInfo'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false, //
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl, //
      'companyId': companyId,
      'guideId': guideId,
      'guideName': guideName,
      'capacity': capacity,
      'city': city,
      'region': region,
      'busInfo': busInfo.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted, //
    };
  }
}
