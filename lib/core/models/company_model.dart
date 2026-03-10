import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String name;
  final String ownerUid;
  final String? logo;
  final String? description;
  final List<String> serviceCities;
  final DateTime createdAt;
  final String iban;
  final String taxNumber;
  final String subMerchantKey;
  final double commissionRate;
  final bool isDeleted;

  CompanyModel({
    required this.id,
    required this.name,
    required this.ownerUid,
    this.logo,
    this.description,
    required this.serviceCities,
    required this.createdAt,
    required this.iban,
    required this.taxNumber,
    required this.subMerchantKey,
    required this.commissionRate,
    this.isDeleted = false,
  });

  factory CompanyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompanyModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      logo: data['logo'],
      description: data['description'],
      serviceCities: List<String>.from(data['serviceCities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      iban: data['iban'] ?? '',
      taxNumber: data['taxNumber'] ?? '',
      subMerchantKey: data['subMerchantKey'] ?? '',
      commissionRate: (data['commissionRate'] ?? 0).toDouble(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ownerUid': ownerUid,
      'logo': logo,
      'description': description,
      'serviceCities': serviceCities,
      'createdAt': Timestamp.fromDate(createdAt),
      'iban': iban,
      'taxNumber': taxNumber,
      'subMerchantKey': subMerchantKey,
      'commissionRate': commissionRate,
      'isDeleted': isDeleted,
    };
  }
}
