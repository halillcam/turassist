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
  final String companyId;
  final String guideId;
  final String? guideName;
  final List<DateTime> availableDates;
  final int capacity;
  final String departureCity;
  final String destinationCity;
  final BusInfo busInfo;
  final DateTime createdAt;
  final bool isActive;

  TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.companyId,
    required this.guideId,
    this.guideName,
    required this.availableDates,
    required this.capacity,
    required this.departureCity,
    required this.destinationCity,
    required this.busInfo,
    required this.createdAt,
    required this.isActive,
  });

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      companyId: data['companyId'] ?? '',
      guideId: data['guideId'] ?? '',
      guideName: data['guideName'],
      availableDates: List<DateTime>.from(
        (data['availableDates'] as List?)?.map((date) => (date as Timestamp).toDate()) ?? [],
      ),
      capacity: data['capacity'] ?? 0,
      departureCity: data['departureCity'] ?? '',
      destinationCity: data['destinationCity'] ?? '',
      busInfo: BusInfo.fromMap(data['busInfo'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'companyId': companyId,
      'guideId': guideId,
      'guideName': guideName,
      'availableDates': availableDates,
      'capacity': capacity,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'busInfo': busInfo.toMap(),
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }
}
