import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String tourId;
  final String userId;
  final String passengerName;
  final String tcNo;
  final DateTime selectedDate;
  final double pricePaid;
  final String status; // 'active', 'checked_in', 'completed', 'cancelled'
  final String? qrCode;
  final bool qrScanned;
  final DateTime purchaseDate;
  final DateTime? scanDate;

  TicketModel({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.passengerName,
    required this.tcNo,
    required this.selectedDate,
    required this.pricePaid,
    required this.status,
    this.qrCode,
    required this.qrScanned,
    required this.purchaseDate,
    this.scanDate,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      tourId: data['tourId'] ?? '',
      userId: data['userId'] ?? '',
      passengerName: data['passengerName'] ?? '',
      tcNo: data['tcNo'] ?? '',
      selectedDate: (data['selectedDate'] as Timestamp).toDate(),
      pricePaid: (data['pricePaid'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      qrCode: data['qrCode'],
      qrScanned: data['qrScanned'] ?? false,
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      scanDate: data['scanDate'] != null ? (data['scanDate'] as Timestamp).toDate() : null,
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return TicketModel(
      id: id ?? (json['id'] ?? ''),
      tourId: json['tourId'] ?? '',
      userId: json['userId'] ?? '',
      passengerName: json['passengerName'] ?? '',
      tcNo: json['tcNo'] ?? '',
      selectedDate: (json['selectedDate'] is Timestamp)
          ? (json['selectedDate'] as Timestamp).toDate()
          : (json['selectedDate'] is String)
          ? DateTime.tryParse(json['selectedDate'] as String) ?? DateTime.now()
          : (json['selectedDate'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(json['selectedDate'] as int)
          : DateTime.now(),
      pricePaid: (json['pricePaid'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      qrCode: json['qrCode'],
      qrScanned: json['qrScanned'] ?? false,
      purchaseDate: (json['purchaseDate'] is Timestamp)
          ? (json['purchaseDate'] as Timestamp).toDate()
          : (json['purchaseDate'] is String)
          ? DateTime.tryParse(json['purchaseDate'] as String) ?? DateTime.now()
          : (json['purchaseDate'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(json['purchaseDate'] as int)
          : DateTime.now(),
      scanDate: json['scanDate'] == null
          ? null
          : (json['scanDate'] is Timestamp)
          ? (json['scanDate'] as Timestamp).toDate()
          : (json['scanDate'] is String)
          ? DateTime.tryParse(json['scanDate'] as String)
          : (json['scanDate'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(json['scanDate'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'userId': userId,
      'passengerName': passengerName,
      'tcNo': tcNo,
      'selectedDate': Timestamp.fromDate(selectedDate),
      'pricePaid': pricePaid,
      'status': status,
      'qrCode': qrCode,
      'qrScanned': qrScanned,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'scanDate': scanDate != null ? Timestamp.fromDate(scanDate!) : null,
    };
  }
}
