import '../../domain/entities/city_choice_entity.dart';
import '../../domain/repositories/city_choice_repository.dart';
import '../datasources/city_choice_local_data_source.dart';

class CityChoiceRepositoryImpl implements CityChoiceRepository {
  CityChoiceRepositoryImpl({CityChoiceLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? CityChoiceLocalDataSource();

  final CityChoiceLocalDataSource _localDataSource;

  @override
  Future<List<CityChoiceEntity>> getCities() {
    return _localDataSource.getCities();
  }

  @override
  Future<String?> getSelectedCity() {
    return _localDataSource.getSelectedCity();
  }

  @override
  Future<void> saveSelectedCity(String city) {
    return _localDataSource.saveSelectedCity(city);
  }
}
