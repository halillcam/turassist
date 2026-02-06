import 'package:get/get.dart';
import 'package:turassist/controllers/tour_controller.dart';
import '../services/firebase_service.dart';

class CityController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var selectedCity = "".obs;
  var cities = <String>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    getCities();
    super.onInit();
  }

  // Tüm şehirleri getir [cite: 12]
  Future<void> getCities() async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getAllCities();
      cities.assignAll(result);
    } catch (e) {
      print('Şehirleri yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Şehir seçildiğinde locale kaydet ve turları filtrelet [cite: 12, 13]
  void updateCity(String city) {
    selectedCity.value = city;
    // Local storage (SecuredSharedPreferences) kaydı buraya [cite: 12]
    Get.find<TourController>().filterByCity(city);
  }
}
