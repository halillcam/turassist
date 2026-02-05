import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/ticket_model.dart';

class BookingController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var myTickets = <TicketModel>[].obs;
  var isLoading = false.obs;

  // Bilet Satın Alma (iyzico entegrasyonu tetikleyici) [cite: 15, 28]
  Future<void> purchaseTicket(String tourId, double price) async {
    isLoading.value = true;
    // Burada iyzico 3D Secure akışı başlayacak
    // Başarılı ise _firebaseService.createTicket çağrılacak
    isLoading.value = false;
  }

  // Bilet İptal Etme
  Future<void> cancelTicket(String ticketId) async {
    try {
      isLoading.value = true;

      // 1. Firebase'de durum güncelle [cite: 7, 35]
      bool success = await _firebaseService.updateTicketStatus(ticketId, 'cancelled');

      if (success) {
        // 2. Local listeden de güncelle veya kaldır
        myTickets.removeWhere((t) => t.id == ticketId);

        Get.snackbar(
          "Başarılı",
          "İade işlemleri başlatıldı.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Hata", "İptal işlemi başarısız: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
