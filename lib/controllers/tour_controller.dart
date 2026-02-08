import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/tour_model.dart';

class TourController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var tours = <TourModel>[].obs;
  var isLoading = true.obs;
  var selectedCity = ''.obs;

  // Bölge sıralaması (sabit)
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

  @override
  void onInit() {
    super.onInit();
    // İlk açılışta otomatik fetch yapmıyoruz,
    // şehir seçildiğinde filterByCity çağrılacak.
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
      selectedCity.value = city;
      var result = await _firebaseService.getToursByCity(city);
      tours.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  // Turları region'a göre grupla (sıralı)
  Map<String, List<TourModel>> get toursByRegion {
    final grouped = <String, List<TourModel>>{};
    for (var tour in tours) {
      final region = tour.region.isEmpty ? 'Diğer' : tour.region;
      if (!grouped.containsKey(region)) {
        grouped[region] = [];
      }
      grouped[region]!.add(tour);
    }

    // regionOrder sırasına göre sırala
    final sorted = <String, List<TourModel>>{};
    for (var region in regionOrder) {
      if (grouped.containsKey(region)) {
        sorted[region] = grouped.remove(region)!;
      }
    }
    // Sırada olmayanları sona ekle
    sorted.addAll(grouped);
    return sorted;
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
