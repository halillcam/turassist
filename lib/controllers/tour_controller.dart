import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/tour_model.dart';

class TourController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var tours = <TourModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchTours(); // Başlangıçta tüm aktif turları çek
    super.onInit();
  }

  // Tüm aktif turları getir (isDeleted: false olanlar)
  void fetchTours() async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getActiveTours();
      tours.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  // Şehre göre filtrele
  void filterByCity(String city) async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getToursByCity(city);
      tours.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  // Tur detayını getir [cite: 13]
  Future<TourModel?> getTourDetail(String tourId) async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getTourById(tourId);
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  // Tur katılımcılarını getir [cite: 32]
  Future<List<dynamic>> getTourParticipants(String tourId) async {
    try {
      var result = await _firebaseService.getTourParticipants(tourId);
      return result;
    } catch (e) {
      print('Katılımcıları yüklerken hata: $e');
      return [];
    }
  }

  // Turu bitir [cite: 6, 32]
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      isLoading.value = true;
      await _firebaseService.finishTour(tourId, guideId);
    } catch (e) {
      print('Turu bitirirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Turu güncelle [cite: 32]
  Future<void> updateTour(String tourId, TourModel updatedTour) async {
    try {
      isLoading.value = true;
      await _firebaseService.updateTour(tourId, updatedTour);
      // Lokaldeki listeyi de güncelle
      final index = tours.indexWhere((t) => t.id == tourId);
      if (index != -1) {
        tours[index] = updatedTour;
      }
    } catch (e) {
      print('Turu güncellerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
