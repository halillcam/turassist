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

      debugPrint('═══ LOAD_DATA: Başladı ═══');

      final userTickets = await _firebaseService.getUserTickets();
      debugPrint('LOAD_DATA: ${userTickets.length} bilet bulundu');
      for (final t in userTickets) {
        debugPrint('  BILET: id=${t.id}, tourId=${t.tourId}, status=${t.status}');
      }
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
            debugPrint('LOAD_DATA: Tur cache\'lendi → ${tour.title}');
          } else {
            debugPrint('LOAD_DATA: Tur bulunamadı → ${ticket.tourId}');
          }
        }
      }

      debugPrint('═══ LOAD_DATA: Tamamlandı ═══');
    } catch (e) {
      errorMessage.value = 'Veriler yüklenirken hata oluştu.';
      debugPrint('LOAD_DATA: HATA → $e');
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
  bool get hasCheckedIn => checkedInTicket.value != null;

  /// Yaklaşan turlar: 'active' durumundaki biletler.
  List<TicketModel> get upcomingTickets => tickets.where((t) => t.status == 'active').toList();

  /// Geçmiş turlar: 'completed' veya 'cancelled' durumundaki biletler.
  List<TicketModel> get pastTickets =>
      tickets.where((t) => t.status == 'completed' || t.status == 'cancelled').toList();

  /// Bilet için QR okutma simülasyonu.
  ///
  /// Biletin turunu aktif tur olarak yükler ve detay görünümüne geçer.
  Future<void> checkInTicket(TicketModel ticket) async {
    checkedInTicket.value = ticket;
    await _loadActiveTourDetail(ticket.tourId);

    Get.snackbar(
      'QR Okutuldu',
      'Tura giriş yapıldı.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  /// Aktif tur görünümünden bilet listesine geri döner.
  void backToTicketList() {
    checkedInTicket.value = null;
    activeTour.value = null;
    programDays.clear();
  }

  /// Verileri yeniden yükler.
  @override
  Future<void> refresh() => loadData();
}
