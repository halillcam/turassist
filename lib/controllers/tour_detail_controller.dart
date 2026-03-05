import 'package:get/get.dart';

import '../models/tour_program_model.dart';
import '../services/tour_service.dart';

/// Tur detay ekranının reaktif state yönetimi.
///
/// [TourDetailScreen] içindeki [TourProgramDay] listesi,
/// yükleme göstergesi ve açıklama genişletme durumu burada tutulur.
/// Böylece ekranda [setState] çağrısına gerek kalmaz.
class TourDetailController extends GetxController {
  final TourService _tourService = TourService();

  /// Tur programı günleri — Firestore'dan yüklenir.
  final RxList<TourProgramDay> programDays = <TourProgramDay>[].obs;

  /// Program yüklenirken true; yükleme tamamlandığında false olur.
  final RxBool isProgramLoading = true.obs;

  /// Tur açıklaması genişletilmiş mi?
  final RxBool isDescriptionExpanded = false.obs;

  /// [tourId] için tur programını Firestore'dan yükler.
  Future<void> loadTourProgram(String tourId) async {
    isProgramLoading.value = true;
    programDays.value = await _tourService.getTourProgram(tourId);
    isProgramLoading.value = false;
  }

  /// Açıklama genişletme/daraltma durumunu tersine çevirir.
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}
