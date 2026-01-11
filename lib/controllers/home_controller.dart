import 'package:get/get.dart';
import 'package:turassist/services/firebase_service.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var selectedCity = ''.obs;
  var availableCities = <String>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableCities();
  }

  Future<void> loadAvailableCities() async {
    isLoading.value = true;
    try {
      final cities = await _firebaseService.getServiceCities();
      availableCities.value = cities;
    } catch (e) {
      print('Error loading cities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCity(String city) {
    selectedCity.value = city;
  }
}
