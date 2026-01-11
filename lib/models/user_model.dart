import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'customer', 'guide', 'admin'
  final String companyId;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    this.profileImage,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      companyId: data['companyId'] ?? '',
      profileImage: data['profileImage'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'companyId': companyId,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
