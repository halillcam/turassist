import 'package:cloud_firestore/cloud_firestore.dart';

/// Uygulamadaki her kullanıcıyı temsil eder.
///
/// Kabul edilen roller:
/// - `customer`    → Tur satın alan normal kullanıcı
/// - `guide`       → Tur sorumlusu (Firebase Auth kullanmaz, guides koleksiyonu)
/// - `admin`       → Şirket yöneticisi (yalnızca web panelinde)
/// - `super_admin` → Platform yöneticisi (yalnızca web panelinde)
class UserModel {
  /// Firebase Auth veya guides koleksiyonundaki belge ID'si.
  final String uid;

  /// Ad + soyad.
  final String fullName;

  final String email;
  final String phone;

  /// Kullanıcı rolü: 'customer' | 'guide' | 'admin' | 'super_admin'.
  final String role;

  /// Kullanıcının bağlı olduğu şirketin ID'si (guide ve admin için).
  final String companyId;

  /// Kullanıcının erişim yetkisi olan şirket ID listesi.
  final List<String> registeredCompanies;

  final String tcNo;

  /// Profil fotoğrafı URL'si (opsiyonel).
  final String? profileImage;

  /// Kullanıcının son seçtiği çıkış şehri.
  final String selectedCity;

  /// Soft-delete bayrağı; true ise kullanıcı silinmiş kabul edilir.
  final bool isDeleted;

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

  /// Firestore belgesinden [UserModel] oluşturur.
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

  /// Firestore'a yazılmak üzere JSON haritasına dönüştürür.
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
