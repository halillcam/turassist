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
}
