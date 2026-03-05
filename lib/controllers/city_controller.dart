import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/city_model.dart';
import 'tour_controller.dart';

/// Şehir seçimi ve kalıcı şehir tercihi yönetimi için controller.
///
/// Sorumlulukları:
/// - SharedPreferences'ta kaydedilen şehri yükleyip geri yazma
/// - Şehir değiştirildiğinde [TourController]'a bildirme
/// - Şehir listesini yerel [cityList]'ten doldurma
class CityController extends GetxController {
  var selectedCity = "".obs;
  var cities = <String>[].obs;
  var isLoading = false.obs;

  /// SharedPreferences'ta kullanılan anahtar.
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

  /// Kaydedilmiş şehri asenkron olarak döndürür (TourListScreen initState için).
  Future<String?> getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  /// Şehir listesini yerel kaynaktan (cityList) günceller.
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

  /// Yeni şehri hem reaktif state'e hem SharedPreferences'a kaydeder
  /// ve [TourController]'a filtreleme komutu gönderir.
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

  /// Kullanıcının bir şehir seçip seçmediğini kontrol eder.
  bool get hasCitySelected => selectedCity.value.isNotEmpty;
}
