/// Kimliği doğrulanmış kullanıcıyı domain seviyesinde temsil eder.
class AuthEntity {
  const AuthEntity({
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

  bool get isGuide => role.trim().toLowerCase() == 'guide';
  bool get isAdmin => role.trim().toLowerCase() == 'admin';
  bool get isSuperAdmin => role.trim().toLowerCase() == 'super_admin';
}
