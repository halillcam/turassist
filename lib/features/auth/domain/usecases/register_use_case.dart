import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Kayıt formunu domain seviyesinde normalize eder.
class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthEntity?> execute({
    required String fullName,
    required String email,
    required String password,
  }) {
    final normalizedFullName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    return _repository.registerCustomer(
      fullName: normalizedFullName,
      email: email.trim(),
      password: password,
    );
  }
}
