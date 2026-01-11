import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String name;
  final String ownerUid;
  final String? logo;
  final String? description;
  final List<String> serviceCities;
  final DateTime createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.ownerUid,
    this.logo,
    this.description,
    required this.serviceCities,
    required this.createdAt,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerUid': ownerUid,
      'logo': logo,
      'description': description,
      'serviceCities': serviceCities,
      'createdAt': createdAt,
    };
  }
}
