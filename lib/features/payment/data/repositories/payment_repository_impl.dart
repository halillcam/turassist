import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/company_model.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<PaymentDraft> prepareMarketplacePayment({required String companyId, required double amount}) async {
    final doc = await _firestore.collection('companies').doc(companyId).get();
    final company = doc.exists
        ? CompanyModel.fromFirestore(doc)
        : CompanyModel(
            id: companyId,
            name: '',
            ownerUid: '',
            serviceCities: const [],
            createdAt: DateTime.now(),
            iban: '',
            taxNumber: '',
            subMerchantKey: '',
            commissionRate: 0,
          );
    final commissionAmount = amount * company.commissionRate;
    final netAmount = amount - commissionAmount;

    return PaymentDraft(
      companyId: companyId,
      subMerchantKey: company.subMerchantKey,
      amount: amount,
      commissionAmount: commissionAmount,
      netAmount: netAmount,
      useThreeDSecure: true,
      isEnabled: false,
    );
  }
}