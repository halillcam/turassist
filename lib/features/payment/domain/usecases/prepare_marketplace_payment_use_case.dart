import '../repositories/payment_repository.dart';

class PrepareMarketplacePaymentUseCase {
  const PrepareMarketplacePaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<PaymentDraft> execute({required String companyId, required double amount}) {
    return _repository.prepareMarketplacePayment(companyId: companyId, amount: amount);
  }
}