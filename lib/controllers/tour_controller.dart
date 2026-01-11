import 'package:get/get.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/services/firebase_service.dart';

class TourController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var selectedCity = ''.obs;
  var tours = <TourModel>[].obs;
  var isLoading = false.obs;

  Future<void> loadToursByCity(String city) async {
    selectedCity.value = city;
    isLoading.value = true;
    try {
      final tourList = await _firebaseService.getToursByCity(city);
      tours.value = tourList;
    } catch (e) {
      print('Error loading tours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<TourModel?> getTourDetails(String tourId) async {
    try {
      return await _firebaseService.getTourById(tourId);
    } catch (e) {
      print('Error getting tour details: $e');
      return null;
    }
  }
}
