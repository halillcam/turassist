import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String tourId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.tourId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.imageUrl,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      tourId: data['tourId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tourId': tourId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
    };
  }
}
