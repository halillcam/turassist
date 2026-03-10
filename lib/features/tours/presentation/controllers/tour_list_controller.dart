import 'package:get/get.dart';

import '../../../../core/models/tour_model.dart';
import '../../../city_choice/presentation/controllers/city_choice_controller.dart';
import '../../data/repositories/tours_repository_impl.dart';
import '../../domain/usecases/get_tours_use_case.dart';

class TourListController extends GetxController {
  TourListController({GetToursUseCase? getToursUseCase})
    : _getToursUseCase = getToursUseCase ?? GetToursUseCase(ToursRepositoryImpl());

  final GetToursUseCase _getToursUseCase;

  final RxList<TourModel> tours = <TourModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCity = ''.obs;
  final RxString searchQuery = ''.obs;

  static const List<String> regionOrder = [
    'Marmara',
    'Ege',
    'Akdeniz',
    'Karadeniz',
    'İç Anadolu',
    'Doğu Anadolu',
    'Güneydoğu Anadolu',
    'Günü Birlik',
    'Yurtdışı',
  ];

  Future<void> initialize(CityChoiceController cityController) async {
    if (tours.isNotEmpty || isLoading.value) {
      return;
    }
    var city = cityController.selectedCity.value;
    if (city.isEmpty) {
      final savedCity = await cityController.getSavedCity();
      if (savedCity != null && savedCity.isNotEmpty) {
        cityController.selectedCity.value = savedCity;
        city = savedCity;
      }
    }
    if (city.isNotEmpty) {
      await loadTours(city: city);
    } else {
      await loadTours();
    }
  }

  Future<void> loadTours({String? city}) async {
    try {
      isLoading.value = true;
      selectedCity.value = city?.trim() ?? '';
      tours.assignAll(await _getToursUseCase.execute(city: city));
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  List<TourModel> get displayTours {
    final bySeries = <String, List<TourModel>>{};
    for (final tour in tours) {
      final key = tour.seriesId ?? tour.id;
      bySeries.putIfAbsent(key, () => <TourModel>[]).add(tour);
    }
    return bySeries.values.map((items) {
      items.sort((left, right) {
        final leftDate = left.departureDate;
        final rightDate = right.departureDate;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return leftDate.compareTo(rightDate);
      });
      return items.first;
    }).toList();
  }

  List<TourModel> filteredTours(List<TourModel> source) {
    if (searchQuery.value.isEmpty) {
      return source;
    }
    return source.where((tour) {
      final query = searchQuery.value;
      return tour.title.toLowerCase().contains(query) ||
          tour.city.toLowerCase().contains(query) ||
          tour.description.toLowerCase().contains(query);
    }).toList();
  }

  List<TourModel> getToursInSeries(TourModel displayTour) {
    if (displayTour.seriesId == null) return [displayTour];
    return tours.where((tour) => tour.seriesId == displayTour.seriesId).toList()
      ..sort((left, right) {
        final leftDate = left.departureDate;
        final rightDate = right.departureDate;
        if (leftDate == null && rightDate == null) return 0;
        if (leftDate == null) return 1;
        if (rightDate == null) return -1;
        return leftDate.compareTo(rightDate);
      });
  }

  Map<String, List<TourModel>> groupByRegion(List<TourModel> source) {
    final grouped = <String, List<TourModel>>{};
    for (final tour in source) {
      final region = tour.region.isEmpty ? 'Diğer' : tour.region;
      grouped.putIfAbsent(region, () => <TourModel>[]).add(tour);
    }

    final sorted = <String, List<TourModel>>{};
    for (final region in regionOrder) {
      if (grouped.containsKey(region)) {
        sorted[region] = grouped.remove(region)!;
      }
    }
    sorted.addAll(grouped);
    return sorted;
  }
}
