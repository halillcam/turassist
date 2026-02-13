import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/ticket_model.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../services/firebase_service.dart';

/// Turlarım ekranı controller'ı.
///
/// Kullanıcının biletlerini, aktif tur durumunu ve
/// tur programını yönetir.
class MyToursController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  // ─── Durum ───
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ─── Bilet Listesi ───
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxMap<String, TourModel> ticketTours = <String, TourModel>{}.obs;
  final RxInt selectedTab = 0.obs;

  // ─── Aktif Tur (QR taranmış) ───
  final Rxn<TicketModel> checkedInTicket = Rxn<TicketModel>();
  final Rxn<TourModel> activeTour = Rxn<TourModel>();
  final RxList<TourProgramDay> programDays = <TourProgramDay>[].obs;

  // ─── Test Modu ───
  final RxBool isTestCheckedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Kullanıcının biletlerini ve ilgili tur verilerini yükler.
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userTickets = await _firebaseService.getUserTickets();
      tickets.assignAll(userTickets);

      // checked_in olan bilet varsa aktif tur olarak yükle
      final checkedIn = userTickets.where((t) => t.status == 'checked_in').toList();
      if (checkedIn.isNotEmpty) {
        checkedInTicket.value = checkedIn.first;
        await _loadActiveTourDetail(checkedIn.first.tourId);
      }

      // Her biletin tur bilgisini cache'le
      for (final ticket in userTickets) {
        if (!ticketTours.containsKey(ticket.tourId)) {
          final tour = await _firebaseService.getTourById(ticket.tourId);
          if (tour != null) {
            ticketTours[ticket.tourId] = tour;
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Veriler yüklenirken hata oluştu.';
      debugPrint('MyToursController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadActiveTourDetail(String tourId) async {
    final tour = await _firebaseService.getTourById(tourId);
    if (tour != null) {
      activeTour.value = tour;
      final program = await _firebaseService.getTourProgram(tourId);
      programDays.assignAll(program);
    }
  }

  /// Aktif (checked_in) bilet var mı?
  bool get hasCheckedIn => checkedInTicket.value != null || isTestCheckedIn.value;

  /// Yaklaşan turlar: 'active' durumundaki biletler.
  List<TicketModel> get upcomingTickets => tickets.where((t) => t.status == 'active').toList();

  /// Geçmiş turlar: 'completed' veya 'cancelled' durumundaki biletler.
  List<TicketModel> get pastTickets =>
      tickets.where((t) => t.status == 'completed' || t.status == 'cancelled').toList();

  /// Test: QR taranmış gibi simüle eder.
  Future<void> simulateCheckIn() async {
    isTestCheckedIn.value = true;

    if (tickets.isNotEmpty) {
      final testTicket = upcomingTickets.isNotEmpty ? upcomingTickets.first : tickets.first;
      checkedInTicket.value = testTicket;
      await _loadActiveTourDetail(testTicket.tourId);
    } else {
      final tours = await _firebaseService.getActiveTours();
      if (tours.isNotEmpty) {
        for (final t in tours) {
          final program = await _firebaseService.getTourProgram(t.id);
          if (program.isNotEmpty) {
            activeTour.value = t;
            programDays.assignAll(program);
            break;
          }
        }
        activeTour.value ??= tours.first;
      }
    }

    Get.snackbar(
      'Test Modu',
      'QR taranmış gibi simüle edildi.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  /// Test: Simülasyonu geri alır.
  void resetCheckIn() {
    isTestCheckedIn.value = false;
    checkedInTicket.value = null;
    activeTour.value = null;
    programDays.clear();

    // Gerçek checked_in bilet varsa geri yükle
    final realCheckedIn = tickets.where((t) => t.status == 'checked_in').toList();
    if (realCheckedIn.isNotEmpty) {
      checkedInTicket.value = realCheckedIn.first;
      _loadActiveTourDetail(realCheckedIn.first.tourId);
    }

    Get.snackbar(
      'Test Modu',
      'Bilet listesine geri dönüldü.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.slate700,
      colorText: Colors.white,
    );
  }

  /// Verileri yeniden yükler.
  @override
  Future<void> refresh() => loadData();
}
