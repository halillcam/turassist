import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secured_shared_preferences.dart';

class GuideLocalDataSource {
  GuideLocalDataSource({SecuredSharedPreferences? storage})
    : _storage = storage ?? SecuredSharedPreferences();

  final SecuredSharedPreferences _storage;

  Future<bool> getIsGuideSession() {
    return _storage.readBool(StorageKeys.isGuideSession);
  }

  Future<String> getGuideId() async {
    return (await _storage.readString(StorageKeys.guideId) ?? '').trim();
  }

  Future<String> getGuideName() async {
    return (await _storage.readString(StorageKeys.guideName) ?? '').trim();
  }
}
