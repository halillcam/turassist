import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'customer', 'guide', 'admin', 'super_admin'
  final String companyId;
  final List<String> registeredCompanies; //
  final String tcNo;
  final String? profileImage;
  final String selectedCity; // Eksik olan şehir tercihi eklendi
  final bool isDeleted; // Firestore ile isim birliği sağlandı
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.registeredCompanies,
    required this.tcNo,
    required this.selectedCity,
    this.profileImage,
    required this.isDeleted,
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
      registeredCompanies: List<String>.from((data['registeredCompanies'] as List?) ?? const []),
      tcNo: data['tcNo'] ?? '',
      selectedCity: data['selectedCity'] ?? '', //
      profileImage: data['profileImage'],
      isDeleted: data['isDeleted'] ?? false, //
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
}
