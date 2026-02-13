import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../services/firebase_service.dart';

class GuideController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var isScanning = false.obs;
  var tourParticipants = <dynamic>[].obs;
  var isLoading = false.obs;
  var currentTourId = "".obs;

  // Tur katılımcılarını getir [cite: 21, 32]
  Future<void> getTourParticipants(String tourId) async {
    try {
      isLoading.value = true;
      currentTourId.value = tourId;
      var result = await _firebaseService.getTourParticipants(tourId);
      tourParticipants.assignAll(result);
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Katılımcıları yüklerken hata: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // QR Kod okutulduğunda çalışacak fonksiyon [cite: 21]
  Future<void> scanTicket(String ticketId) async {
    try {
      isScanning.value = true;
      bool success = await _firebaseService.updateTicketQRStatus(ticketId);

      if (success) {
        // Katılımcı listesini güncelle
        getTourParticipants(currentTourId.value);
        Get.snackbar(
          "Başarılı",
          "Bilet onaylandı, yolcu içeri alınabilir.",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Hata",
          "Bilet geçersiz veya daha önce okutulmuş.",
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Bilet okutma başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isScanning.value = false;
    }
  }

  // Katılımcılara bildirim gönder [cite: 21, 25]
  Future<void> sendNotificationToParticipants(String tourId, String message) async {
    try {
      isLoading.value = true;
      await _firebaseService.sendNotificationToTourParticipants(tourId, message);
      Get.snackbar(
        "Başarılı",
        "Bildirim katılımcılara gönderildi.",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Bildirim gönderme başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Turu bitir [cite: 6, 21]
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      isLoading.value = true;
      await _firebaseService.finishTour(tourId, guideId);

      Get.snackbar(
        "Başarılı",
        "Tur bitirme talebi şirkete gönderildi. Onay bekleniyor...",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Bir süre sonra navigate et
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/guide-dashboard');
      });
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Turu bitirme başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
