import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secured_shared_preferences.dart';
import '../../domain/entities/auth_entity.dart';

/// Auth feature'ın local persistence sınırıdır.
class AuthLocalDataSource {
  AuthLocalDataSource({SecuredSharedPreferences? storage})
    : _storage = storage ?? SecuredSharedPreferences();

  final SecuredSharedPreferences _storage;

  Future<void> persistGuideSession(AuthEntity user) async {
    await _storage.writeMirroredBool(StorageKeys.isGuideSession, true);
    await _storage.writeMirroredString(StorageKeys.guideId, user.uid);
    await _storage.writeMirroredString(StorageKeys.guideName, user.fullName);
  }

  Future<void> clearGuideSession() {
    return _storage.clearKeys(const [
      StorageKeys.isGuideSession,
      StorageKeys.guideId,
      StorageKeys.guideName,
    ]);
  }

  Future<String?> getSelectedCity() {
    return _storage.readString(StorageKeys.selectedCity);
  }
}
