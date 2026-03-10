class PaymentDraft {
  const PaymentDraft({
    required this.companyId,
    required this.subMerchantKey,
    required this.amount,
    required this.commissionAmount,
    required this.netAmount,
    required this.useThreeDSecure,
    required this.isEnabled,
  });

  final String companyId;
  final String subMerchantKey;
  final double amount;
  final double commissionAmount;
  final double netAmount;
  final bool useThreeDSecure;
  final bool isEnabled;
}

abstract class PaymentRepository {
  Future<PaymentDraft> prepareMarketplacePayment({
    required String companyId,
    required double amount,
  });
}
