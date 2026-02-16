import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/city_model.dart';
import 'tour_controller.dart';

class CityController extends GetxController {
  var selectedCity = "".obs;
  var cities = <String>[].obs;
  var isLoading = false.obs;

  static const String _cityKey = 'selected_city';

  @override
  void onInit() {
    super.onInit();
    getCities();
    _loadSavedCity();
  }

  // Local'den kayıtlı şehri yükle
  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString(_cityKey);
      if (savedCity != null && savedCity.isNotEmpty) {
        selectedCity.value = savedCity;
        // TourController register edilmişse turları çek
        if (Get.isRegistered<TourController>()) {
          Get.find<TourController>().filterByCity(savedCity);
        }
      }
    } catch (e) {
      debugPrint('Kayıtlı şehir yüklenirken hata: $e');
    }
  }

  // Kayıtlı şehri döner (async - TourListScreen initState için)
  Future<String?> getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  // Tüm şehirleri getir [cite: 12]
  Future<void> getCities() async {
    try {
      isLoading.value = true;
      cities.assignAll(cityList.map((item) => item.name));
    } catch (e) {
      debugPrint('Şehirleri yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Şehir seçildiğinde locale kaydet ve turları filtrelet [cite: 12, 13]
  Future<void> updateCity(String city) async {
    selectedCity.value = city;
    // SharedPreferences'a kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
    // Turları filtrele
    if (Get.isRegistered<TourController>()) {
      Get.find<TourController>().filterByCity(city);
    }
  }

  // Şehir seçilmiş mi kontrol et
  bool get hasCitySelected => selectedCity.value.isNotEmpty;
}
