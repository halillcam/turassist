import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/announcement_entity.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.scope,
    required this.senderRole,
    required this.senderName,
  });

  final String id;
  final String message;
  final DateTime createdAt;
  final String scope;
  final String senderRole;
  final String senderName;

  factory AnnouncementModel.fromAnnouncementDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementModel(
      id: doc.id,
      message: data['notification']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scope: data['scope']?.toString() ?? 'checked_in_only',
      senderRole: data['senderRole']?.toString() ?? '',
      senderName: data['senderName']?.toString() ?? '',
    );
  }

  factory AnnouncementModel.fromNotificationDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementModel(
      id: doc.id,
      message: data['message']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scope: data['scope']?.toString() ?? 'checked_in_only',
      senderRole: data['senderRole']?.toString() ?? '',
      senderName: data['senderName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toAnnouncementJson() {
    return {
      'notification': message,
      'createdAt': FieldValue.serverTimestamp(),
      'scope': scope,
      'senderRole': senderRole,
      'senderName': senderName,
    };
  }

  AnnouncementEntity toEntity() {
    return AnnouncementEntity(
      id: id,
      message: message,
      createdAt: createdAt,
      scope: scope,
      senderRole: senderRole,
      senderName: senderName,
    );
  }
}
