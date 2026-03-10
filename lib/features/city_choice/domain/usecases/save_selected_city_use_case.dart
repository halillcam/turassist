import '../repositories/city_choice_repository.dart';

class SaveSelectedCityUseCase {
  SaveSelectedCityUseCase(this._repository);

  final CityChoiceRepository _repository;

  Future<void> execute(String city) {
    return _repository.saveSelectedCity(city);
  }
}
