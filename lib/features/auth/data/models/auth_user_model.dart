import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/auth_entity.dart';

/// Firestore/FirebaseAuth verisinin auth feature içindeki DTO karşılığı.
class AuthUserModel {
  const AuthUserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.registeredCompanies,
    required this.tcNo,
    required this.selectedCity,
    required this.profileImage,
    required this.isDeleted,
    required this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String companyId;
  final List<String> registeredCompanies;
  final String tcNo;
  final String selectedCity;
  final String? profileImage;
  final bool isDeleted;
  final DateTime createdAt;

  factory AuthUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return AuthUserModel(
      uid: document.id,
      fullName: data['fullName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'customer',
      companyId: data['companyId']?.toString() ?? '',
      registeredCompanies: List<String>.from(data['registeredCompanies'] as List? ?? const []),
      tcNo: data['tcNo']?.toString() ?? '',
      selectedCity: data['selectedCity']?.toString() ?? '',
      profileImage: data['profileImage']?.toString(),
      isDeleted: data['isDeleted'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'companyId': companyId,
      'registeredCompanies': registeredCompanies,
      'tcNo': tcNo,
      'selectedCity': selectedCity,
      'profileImage': profileImage,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      uid: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      companyId: companyId,
      registeredCompanies: registeredCompanies,
      tcNo: tcNo,
      selectedCity: selectedCity,
      profileImage: profileImage,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }
}
