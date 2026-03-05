import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/ticket_model.dart';
import '../services/firebase_service.dart';

/// Bilet satın alma ve iade işlemlerini yöneten controller.
///
/// Sorumlulukları:
/// - Kullanıcının biletlerini uygulama başlatıldığında yükleme
/// - Tur rezervasyonu oluşturma (bilet + QR token)
/// - Bilet iptal etme (durum güncellemesi + lokal kaldırma)
class BookingController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var myTickets = <TicketModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchMyTickets();
    super.onInit();
  }

  /// Kullanıcının satın aldığı biletleri Firestore'dan getirir.
  Future<void> fetchMyTickets() async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getUserTickets();
      myTickets.assignAll(result);
    } catch (e) {
      debugPrint('Biletleri yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Tur rezervasyonu oluşturur: bilet ve QR token birlikte kaydedilir.
  ///
  /// Başarılı işlem sonrası [myTickets] güncellenir ve başarı mesajı gösterilir.
  Future<void> purchaseTicket({
    required String tourId,
    required String slotId,
    required String companyId,
    required String passengerName,
    required String tcNo,
    required double price,
    required String subMerchantKey,
    DateTime? departureDate,
  }) async {
    try {
      isLoading.value = true;

      final userId = _firebaseService.getCurrentUserId();
      debugPrint('═══ PURCHASE: Başladı ═══');
      debugPrint('PURCHASE: userId=$userId');
      debugPrint('PURCHASE: tourId=$tourId, slotId=$slotId');

      if (userId.isEmpty) {
        debugPrint('PURCHASE: HATA — userId boş! Kullanıcı giriş yapmamış.');
        Get.snackbar(
          'Hata',
          'Giriş yapılmamış',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      TicketModel newTicket = TicketModel(
        id: '',
        tourId: tourId,
        userId: userId,
        companyId: companyId,
        slotId: slotId,
        passengerName: passengerName,
        tcNo: tcNo,
        pricePaid: price,
        status: 'active',
        qrToken: '',
        isScanned: false,
        purchaseDate: DateTime.now(),
        scannedAt: null,
        departureDate: departureDate,
      );

      debugPrint('PURCHASE: Bilet + QR tek adımda oluşturuluyor...');
      final created = await _firebaseService.createTicket(newTicket);
      final ticketId = created.ticketId;
      final qrToken = created.qrToken;
      debugPrint('PURCHASE: Bilet oluşturuldu → ticketId=$ticketId');
      debugPrint('PURCHASE: QR token oluşturuldu ve kaydedildi ✓');

      myTickets.add(
        TicketModel(
          id: ticketId,
          tourId: newTicket.tourId,
          userId: newTicket.userId,
          companyId: newTicket.companyId,
          slotId: newTicket.slotId,
          passengerName: newTicket.passengerName,
          tcNo: newTicket.tcNo,
          pricePaid: newTicket.pricePaid,
          status: newTicket.status,
          qrToken: qrToken,
          isScanned: newTicket.isScanned,
          purchaseDate: newTicket.purchaseDate,
          scannedAt: newTicket.scannedAt,
          departureDate: newTicket.departureDate,
        ),
      );

      Get.snackbar(
        'Başarılı',
        'Bilet başarıyla satın alındı!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      debugPrint('═══ PURCHASE: Tamamlandı ═══');
    } catch (e) {
      debugPrint('PURCHASE: HATA → $e');
      Get.snackbar(
        'Hata',
        'Satın alma işlemi başarısız: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Bilet iptal eder: Firestore'da durumu 'cancelled' yapıp lokal listeden kaldırır.
  Future<void> cancelTicket(String ticketId) async {
    try {
      isLoading.value = true;

      // 1. Firebase'de durum güncelle
      bool success = await _firebaseService.updateTicketStatus(ticketId, 'cancelled');

      if (success) {
        // 2. Local listeden de güncelle
        myTickets.removeWhere((t) => t.id == ticketId);

        Get.snackbar(
          "Başarılı",
          "İade işlemleri başlatıldı. Paranız hesabınıza iade edilecektir.",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        "İptal işlemi başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
