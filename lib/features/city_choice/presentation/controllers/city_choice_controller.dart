import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../data/repositories/city_choice_repository_impl.dart';
import '../../domain/entities/city_choice_entity.dart';
import '../../domain/repositories/city_choice_repository.dart';
import '../../domain/usecases/get_available_cities_use_case.dart';
import '../../domain/usecases/load_selected_city_use_case.dart';
import '../../domain/usecases/save_selected_city_use_case.dart';

/// City choice feature'ın presentation state'ini yönetir.
class CityChoiceController extends GetxController {
  CityChoiceController({CityChoiceRepository? repository})
    : _repository = repository ?? CityChoiceRepositoryImpl() {
    _getAvailableCitiesUseCase = GetAvailableCitiesUseCase(_repository);
    _loadSelectedCityUseCase = LoadSelectedCityUseCase(_repository);
    _saveSelectedCityUseCase = SaveSelectedCityUseCase(_repository);
  }

  final CityChoiceRepository _repository;
  late final GetAvailableCitiesUseCase _getAvailableCitiesUseCase;
  late final LoadSelectedCityUseCase _loadSelectedCityUseCase;
  late final SaveSelectedCityUseCase _saveSelectedCityUseCase;

  final RxString selectedCity = ''.obs;
  final RxList<String> cities = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<CityChoiceEntity> filteredCities = <CityChoiceEntity>[].obs;
  final RxString searchQuery = ''.obs;
  final List<CityChoiceEntity> _allCities = <CityChoiceEntity>[];

  @override
  void onInit() {
    super.onInit();
    loadInitialState();
  }

  bool get hasCitySelected => selectedCity.value.isNotEmpty;

  Future<void> loadInitialState() async {
    try {
      isLoading.value = true;
      final loadedCities = await _getAvailableCitiesUseCase.execute();
      _allCities
        ..clear()
        ..addAll(loadedCities);
      cities.assignAll(loadedCities.map((city) => city.name));
      final savedCity = await _loadSelectedCityUseCase.execute();
      if (savedCity != null && savedCity.isNotEmpty) {
        selectedCity.value = savedCity;
      }
      _applyFilter(searchQuery.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getSavedCity() {
    return _loadSelectedCityUseCase.execute();
  }

  void searchCities(String query) {
    searchQuery.value = query;
    _applyFilter(query);
  }

  void selectCity(String city) {
    selectedCity.value = city;
  }

  Future<void> updateCity(String city) async {
    selectedCity.value = city;
    await _saveSelectedCityUseCase.execute(city);
  }

  Future<void> continueWithSelection() async {
    if (!hasCitySelected) {
      return;
    }
    await updateCity(selectedCity.value);
    Get.offAllNamed(AppRoutes.tourList);
  }

  void _applyFilter(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      filteredCities.assignAll(_allCities);
      return;
    }

    filteredCities.assignAll(
      _allCities.where((city) => city.name.toLowerCase().contains(normalizedQuery)),
    );
  }
}
