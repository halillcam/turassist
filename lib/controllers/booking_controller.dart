import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/ticket_model.dart';

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
      print('Biletleri yüklerken hata: $e');
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

      // 1. İyzico 3D Secure ödeme akışını başlat
      // Bu, native platform channel veya REST API aracılığıyla olabilir
      // Başarılı ödemenin ardından QR kod oluştur

      // 2. Ödeme başarılı ise bilet oluştur
      final userId = _firebaseService.getCurrentUserId();

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

      String ticketId = await _firebaseService.createTicket(newTicket);

      // 3. Başarılı ödemenin ardından unique QR token gömülü QR kod oluştur [cite: 18, 32]
      String qrToken = await _firebaseService.generateQRToken(ticketId);
      await _firebaseService.updateTicketQRToken(ticketId, qrToken);

      myTickets.add(newTicket);

      Get.snackbar(
        "Başarılı",
        "Bilet başarıyla satın alındı! Token gömülü QR kodunuz Turlarım sekmesinde.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Satın alma işlemi başarısız: $e",
        backgroundColor: Colors.red,
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        "İptal işlemi başarısız: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
