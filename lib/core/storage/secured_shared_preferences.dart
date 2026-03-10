import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences anahtarlarını güvenli storage ile aynalayan yardımcı katman.
class SecuredSharedPreferences {
  SecuredSharedPreferences({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();

  Future<String?> readString(String key) async {
    final prefs = await _preferences;
    final legacyValue = prefs.getString(key);
    if (legacyValue != null && legacyValue.isNotEmpty) {
      await _secureStorage.write(key: key, value: legacyValue);
      return legacyValue;
    }

    final secureValue = await _secureStorage.read(key: key);
    if (secureValue != null && secureValue.isNotEmpty) {
      await prefs.setString(key, secureValue);
    }
    return secureValue;
  }

  Future<void> writeMirroredString(String key, String value) async {
    final prefs = await _preferences;
    await prefs.setString(key, value);
    await _secureStorage.write(key: key, value: value);
  }

  Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final prefs = await _preferences;
    if (prefs.containsKey(key)) {
      final legacyValue = prefs.getBool(key) ?? defaultValue;
      await _secureStorage.write(key: key, value: legacyValue.toString());
      return legacyValue;
    }

    final secureValue = await _secureStorage.read(key: key);
    if (secureValue == null) {
      return defaultValue;
    }

    final normalizedValue = secureValue.toLowerCase() == 'true';
    await prefs.setBool(key, normalizedValue);
    return normalizedValue;
  }

  Future<void> writeMirroredBool(String key, bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(key, value);
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<void> remove(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
    await _secureStorage.delete(key: key);
  }

  Future<void> clearKeys(Iterable<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
  }
}
