import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  /// Tur programı yüklenirken true; yükleme tamamlandığında false olur.
  final RxBool isProgramLoading = true.obs;

  /// Tur açıklaması genişletilmiş mi?
  final RxBool isDescriptionExpanded = false.obs;

  /// Tur firmasının adı — Firestore companies koleksiyonundan çekilir.
  final RxString companyName = ''.obs;

  /// [tourId] için tur programını Firestore'dan yükler.
  Future<void> loadTourProgram(String tourId) async {
    isProgramLoading.value = true;
    programDays.value = await _tourService.getTourProgram(tourId);
    isProgramLoading.value = false;
  }

  /// [companyId] ile Firestore companies koleksiyonundan firma adını yükler.
  ///
  /// Tur dokümanında zaten `companyName` varsa önce onu kullanır,
  /// yoksa companies koleksiyonunda `companyName -> name` fallback'i uygular.
  Future<void> loadCompanyName(String companyId, {String? initialCompanyName}) async {
    final seededName = initialCompanyName?.trim() ?? '';
    if (seededName.isNotEmpty) {
      companyName.value = seededName;
    }
    if (companyId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('companies').doc(companyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final name = (data['companyName'] ?? data['name'] ?? data['company_names'] ?? '')
            .toString()
            .trim();
        if (name.isNotEmpty) {
          companyName.value = name;
        }
      } else {
        debugPrint('loadCompanyName: companies/$companyId dokümanı bulunamadı');
      }
    } catch (e) {
      debugPrint('loadCompanyName error: $e');
    }
  }

  /// Açıklama genişletme/daraltma durumunu tersine çevirir.
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}
