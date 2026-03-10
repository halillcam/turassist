import '../repositories/city_choice_repository.dart';

class LoadSelectedCityUseCase {
  LoadSelectedCityUseCase(this._repository);

  final CityChoiceRepository _repository;

  Future<String?> execute() {
    return _repository.getSelectedCity();
  }
}
