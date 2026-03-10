import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      senderId: data['senderId']?.toString() ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole']?.toString() ?? 'customer',
      text: data['text'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
