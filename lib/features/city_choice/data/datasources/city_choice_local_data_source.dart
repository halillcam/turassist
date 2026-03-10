import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secured_shared_preferences.dart';
import '../../../../core/models/city_model.dart';
import '../../domain/entities/city_choice_entity.dart';

/// Şehir listesini lokal modelden, seçimi ise güvenli storage katmanından okur.
class CityChoiceLocalDataSource {
  CityChoiceLocalDataSource({SecuredSharedPreferences? storage})
    : _storage = storage ?? SecuredSharedPreferences();

  final SecuredSharedPreferences _storage;

  Future<List<CityChoiceEntity>> getCities() async {
    return cityList
        .map(
          (city) => CityChoiceEntity(
            name: city.name,
            regionName: city.region.displayName,
            imagePath: city.imagePath,
            networkImageUrl: city.networkImageUrl,
            isAvailable: city.isAvailable,
          ),
        )
        .toList();
  }

  Future<String?> getSelectedCity() {
    return _storage.readString(StorageKeys.selectedCity);
  }

  Future<void> saveSelectedCity(String city) {
    return _storage.writeMirroredString(StorageKeys.selectedCity, city);
  }
}
