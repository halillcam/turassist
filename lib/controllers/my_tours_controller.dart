import 'dart:async';

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
/// tur programını yönetir. Firestore real-time listener
/// sayesinde rehber QR okuttuğunda ekran otomatik güncellenir.
class MyToursController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<TicketModel>>? _ticketSubscription;

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
    _startTicketListener();

    // Yedek mekanizma: tickets listesi her değiştiğinde checked_in değerlendir.
    // Stream listener async gecikmelerinden bağımsız çalışır.
    ever(tickets, (_) => _evaluateCheckedInState());
  }

  @override
  void onClose() {
    _ticketSubscription?.cancel();
    super.onClose();
  }

  /// Bilet listesinden checked_in durumunu değerlendirir.
  /// Stream listener veya `ever()` watcher tarafından tetiklenir.
  void _evaluateCheckedInState() {
    final checkedIn = tickets.where((t) => t.status == 'checked_in' || t.isScanned).toList();

    if (checkedIn.isNotEmpty) {
      final incoming = checkedIn.first;
      final current = checkedInTicket.value;
      if (current == null ||
          current.id != incoming.id ||
          current.isScanned != incoming.isScanned ||
          current.status != incoming.status) {
        debugPrint(
          'EVALUATE: checked_in bilet tespit → ${incoming.id} '
          '(isScanned=${incoming.isScanned}, status=${incoming.status})',
        );
        checkedInTicket.value = incoming;
        // Tur detaylarını arka planda yükle (UI zaten spinner gösterir)
        _loadActiveTourDetail(incoming.tourId);
      }
    } else if (checkedInTicket.value != null) {
      debugPrint('EVALUATE: checked_in bilet yok → listeye dön');
      checkedInTicket.value = null;
      activeTour.value = null;
      programDays.clear();
    }
  }

  /// Firestore real-time listener: bilet durumu değiştiğinde (örn. rehber
  /// QR okuttuğunda `isScanned` → true) ekranı otomatik günceller.
  void _startTicketListener() {
    _ticketSubscription?.cancel();
    _ticketSubscription = _firebaseService.getUserTicketsStream().listen(
      (updatedTickets) async {
        debugPrint('TICKET_STREAM: ${updatedTickets.length} bilet güncellendi');

        // Biletleri hemen güncelle → ever(tickets, ...) otomatik tetiklenir
        // ve checked_in durumu HEMEN değerlendirilir (await beklemeden).
        tickets.assignAll(updatedTickets);

        // Tur bilgilerini arka planda cache'le
        for (final ticket in updatedTickets) {
          if (!ticketTours.containsKey(ticket.tourId)) {
            final tour = await _firebaseService.getTourById(ticket.tourId);
            if (tour != null) {
              ticketTours[ticket.tourId] = tour;
            }
          }
        }

        // Stream ilk veriyi getirdiğinde loading'i kapat
        if (isLoading.value) {
          isLoading.value = false;
        }
      },
      onError: (e) {
        debugPrint('TICKET_STREAM: HATA → $e');
        if (isLoading.value) {
          isLoading.value = false;
        }
      },
    );
  }

  /// Kullanıcının biletlerini ve ilgili tur verilerini yükler (ilk yükleme).
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('═══ LOAD_DATA: Başladı ═══');

      final userTickets = await _firebaseService.getUserTickets();
      debugPrint('LOAD_DATA: ${userTickets.length} bilet bulundu');
      tickets.assignAll(userTickets);

      // checked_in veya isScanned olan bilet varsa aktif tur olarak yükle
      final checkedIn = userTickets.where((t) => t.status == 'checked_in' || t.isScanned).toList();
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

  Future<void> cancelUpcomingTicket(TicketModel ticket) async {
    if (ticket.status != 'active') {
      Get.snackbar(
        'İptal Edilemez',
        'Sadece aktif biletler iptal edilebilir.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _firebaseService.updateTicketStatus(ticket.id, 'cancelled');
    if (!success) {
      Get.snackbar(
        'Hata',
        'Tur iptal işlemi başarısız oldu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final index = tickets.indexWhere((item) => item.id == ticket.id);
    if (index != -1) {
      final old = tickets[index];
      tickets[index] = TicketModel(
        id: old.id,
        tourId: old.tourId,
        userId: old.userId,
        companyId: old.companyId,
        slotId: old.slotId,
        passengerName: old.passengerName,
        tcNo: old.tcNo,
        pricePaid: old.pricePaid,
        status: 'cancelled',
        qrToken: old.qrToken,
        isScanned: old.isScanned,
        purchaseDate: old.purchaseDate,
        scannedAt: old.scannedAt,
      );
      tickets.refresh();
    }

    Get.snackbar(
      'İptal Edildi',
      'Tur başarıyla iptal edildi.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  /// Bilet için QR okutma simülasyonu.
  ///
  /// Biletin turunu aktif tur olarak yükler ve detay görünümüne geçer.
  Future<void> checkInTicket(TicketModel ticket) async {
    // Simülasyonda da rehber paneline yansıması için Firestore'a check-in bilgisi yaz.
    final qrUpdateOk = await _firebaseService.updateTicketQRStatus(ticket.id);
    final statusFallbackOk = qrUpdateOk
        ? true
        : await _firebaseService.updateTicketStatus(ticket.id, 'checked_in');

    if (!statusFallbackOk) {
      Get.snackbar(
        'QR Okutma Hatası',
        'Check-in bilgisi kaydedilemedi. Firestore yetkilerini kontrol edin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final updatedTicket = TicketModel(
      id: ticket.id,
      tourId: ticket.tourId,
      userId: ticket.userId,
      companyId: ticket.companyId,
      slotId: ticket.slotId,
      passengerName: ticket.passengerName,
      tcNo: ticket.tcNo,
      pricePaid: ticket.pricePaid,
      status: 'checked_in',
      qrToken: ticket.qrToken,
      isScanned: qrUpdateOk ? true : ticket.isScanned,
      purchaseDate: ticket.purchaseDate,
      scannedAt: DateTime.now(),
    );

    final index = tickets.indexWhere((item) => item.id == ticket.id);
    if (index != -1) {
      tickets[index] = updatedTicket;
      tickets.refresh();
    }

    checkedInTicket.value = updatedTicket;
    await _loadActiveTourDetail(updatedTicket.tourId);

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
