import '../entities/city_choice_entity.dart';
import '../repositories/city_choice_repository.dart';

class GetAvailableCitiesUseCase {
  GetAvailableCitiesUseCase(this._repository);

  final CityChoiceRepository _repository;

  Future<List<CityChoiceEntity>> execute() {
    return _repository.getCities();
  }
}
