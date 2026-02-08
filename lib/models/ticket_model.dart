import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id;
  final String tourId;
  final String userId;
  final String companyId; // Eklendi: Security rules için şart
  final String slotId; // Eklendi: Hangi tarihteki tur olduğu bilgisi
  final String passengerName;
  final String tcNo;
  final double pricePaid;
  final String status; // 'active', 'checked_in', 'completed', 'cancelled'
  final String? qrToken; // 'qrCode' -> 'qrToken' olarak güncellendi (Rules uyumu)
  final bool isScanned; // 'qrScanned' -> 'isScanned' olarak güncellendi
  final DateTime purchaseDate;
  final DateTime? scannedAt; // 'scanDate' -> 'scannedAt' (Rules uyumu)

  TicketModel({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.companyId,
    required this.slotId,
    required this.passengerName,
    required this.tcNo,
    required this.pricePaid,
    required this.status,
    this.qrToken,
    required this.isScanned,
    required this.purchaseDate,
    this.scannedAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      tourId: data['tourId'] ?? '',
      userId: data['userId'] ?? '',
      companyId: data['companyId'] ?? '', //
      slotId: data['slotId'] ?? '', //
      passengerName: data['passengerName'] ?? '',
      tcNo: data['tcNo'] ?? '',
      pricePaid: (data['pricePaid'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      qrToken: data['qrToken'], //
      isScanned: data['isScanned'] ?? false, //
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate(), //
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'userId': userId,
      'companyId': companyId,
      'slotId': slotId,
      'passengerName': passengerName,
      'tcNo': tcNo,
      'pricePaid': pricePaid,
      'status': status,
      'qrToken': qrToken,
      'isScanned': isScanned,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'scannedAt': scannedAt != null ? Timestamp.fromDate(scannedAt!) : null,
    };
  }
}
