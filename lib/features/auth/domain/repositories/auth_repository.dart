import '../entities/auth_entity.dart';
import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Future<AuthSessionEntity?> loginWithEmail({
    required String email,
    required String password,
    required String companyId,
  });

  Future<AuthSessionEntity?> loginWithGuideId({required String guideId, required String password});

  Future<AuthSessionEntity?> loginWithSyntheticCustomer({
    required String email,
    required String password,
  });

  Future<AuthSessionEntity?> signInWithGoogle();

  Future<AuthEntity?> registerCustomer({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> persistGuideSession(AuthEntity user);

  Future<void> clearGuideSession();

  Future<String?> getSelectedCity();
}
