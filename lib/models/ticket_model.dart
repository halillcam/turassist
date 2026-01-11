import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String tourId;
  final String userId;
  final String passengerName;
  final String tcNo;
  final DateTime selectedDate;
  final double pricePaid;
  final String status; // 'active', 'completed', 'cancelled'
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

  Map<String, dynamic> toMap() {
    return {
      'tourId': tourId,
      'userId': userId,
      'passengerName': passengerName,
      'tcNo': tcNo,
      'selectedDate': selectedDate,
      'pricePaid': pricePaid,
      'status': status,
      'qrCode': qrCode,
      'qrScanned': qrScanned,
      'purchaseDate': purchaseDate,
      'scanDate': scanDate,
    };
  }
}
