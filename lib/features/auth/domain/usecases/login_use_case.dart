import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Giriş tipini çözer ve doğru repository akışını çalıştırır.
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;
  static final RegExp _guideIdPattern = RegExp(r'^[A-Za-z0-9\-]+$');

  Future<AuthSessionEntity?> execute({
    required String identity,
    required String password,
    required String companyId,
  }) async {
    final normalizedIdentity = identity.trim();
    if (!normalizedIdentity.contains('@') && _guideIdPattern.hasMatch(normalizedIdentity)) {
      return _repository.loginWithGuideId(guideId: normalizedIdentity, password: password);
    }

    if (normalizedIdentity.toLowerCase().endsWith('@customer.turassist')) {
      return _repository.loginWithSyntheticCustomer(email: normalizedIdentity, password: password);
    }

    return _repository.loginWithEmail(
      email: normalizedIdentity,
      password: password,
      companyId: companyId,
    );
  }
}
