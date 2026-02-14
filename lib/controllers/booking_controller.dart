import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/ticket_model.dart';
import '../services/firebase_service.dart';

class BookingController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var myTickets = <TicketModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchMyTickets();
    super.onInit();
  }

  // Kullanıcının satın aldığı biletleri yükle [cite: 15]
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

  // Bilet Satın Alma (iyzico entegrasyonu tetikleyici) [cite: 15, 28]
  Future<void> purchaseTicket({
    required String tourId,
    required String slotId,
    required String companyId,
    required String passengerName,
    required String tcNo,
    required double price,
    required String subMerchantKey,
  }) async {
    try {
      isLoading.value = true;

      final userId = _firebaseService.getCurrentUserId();
      debugPrint('═══ PURCHASE: Başladı ═══');
      debugPrint('PURCHASE: userId=$userId');
      debugPrint('PURCHASE: tourId=$tourId');

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
      );

      debugPrint('PURCHASE: Bilet oluşturuluyor...');
      String ticketId = await _firebaseService.createTicket(newTicket);
      debugPrint('PURCHASE: Bilet oluşturuldu → ticketId=$ticketId');

      String qrToken = await _firebaseService.generateQRToken(ticketId);
      await _firebaseService.updateTicketQRToken(ticketId, qrToken);
      debugPrint('PURCHASE: QR token kaydedildi ✓');

      myTickets.add(newTicket);

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

  // Bilet İptal Etme [cite: 7, 35]
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
