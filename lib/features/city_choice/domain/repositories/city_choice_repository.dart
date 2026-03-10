import '../entities/city_choice_entity.dart';

abstract class CityChoiceRepository {
  Future<List<CityChoiceEntity>> getCities();

  Future<String?> getSelectedCity();

  Future<void> saveSelectedCity(String city);
}
