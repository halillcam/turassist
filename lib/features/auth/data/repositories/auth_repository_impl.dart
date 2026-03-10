import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource, AuthLocalDataSource? localDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
      _localDataSource = localDataSource ?? AuthLocalDataSource();

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthSessionEntity?> loginWithEmail({
    required String email,
    required String password,
    required String companyId,
  }) {
    return _remoteDataSource.loginWithEmail(email: email, password: password, companyId: companyId);
  }

  @override
  Future<AuthSessionEntity?> loginWithGuideId({required String guideId, required String password}) {
    return _remoteDataSource.loginWithGuideId(guideId: guideId, password: password);
  }

  @override
  Future<AuthSessionEntity?> loginWithSyntheticCustomer({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.loginWithSyntheticCustomer(email: email, password: password);
  }

  @override
  Future<AuthSessionEntity?> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AuthEntity?> registerCustomer({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final model = await _remoteDataSource.registerCustomer(
      fullName: fullName,
      email: email,
      password: password,
    );
    return model?.toEntity();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> persistGuideSession(AuthEntity user) {
    return _localDataSource.persistGuideSession(user);
  }

  @override
  Future<void> clearGuideSession() {
    return _localDataSource.clearGuideSession();
  }

  @override
  Future<String?> getSelectedCity() {
    return _localDataSource.getSelectedCity();
  }
}
