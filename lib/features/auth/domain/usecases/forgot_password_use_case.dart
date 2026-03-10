import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(String email) {
    return _repository.sendPasswordResetEmail(email.trim());
  }
}
