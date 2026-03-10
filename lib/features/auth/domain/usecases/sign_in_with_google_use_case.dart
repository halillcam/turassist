import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSessionEntity?> execute() {
    return _repository.signInWithGoogle();
  }
}
