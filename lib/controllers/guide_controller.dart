import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';

/// Rehber (tur sorumlusu) işlemlerini yöneten controller.
///
/// Sorumlulukları:
/// - Tur katılımcı listesini yükleme
/// - QR bilet doğrulama ve check-in (ID bazlı eski API)
/// - Katılımcılara duyuru gönderme
/// - Turu bitirme talebi oluşturma
class GuideController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  /// Tarama işlemi devam ediyor mu?
  var isScanning = false.obs;

  /// Yüklenmiş katılımcı listesi.
  var tourParticipants = <dynamic>[].obs;
  var isLoading = false.obs;

  /// Aktif turın ID'si.
  var currentTourId = "".obs;

  /// Tura ait iptal edilmemiş katılımcıları Firestore'dan getirir.
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

  /// Bilet ID'si ile QR tarama yapar (eski ID-bazlı API).
  ///
  /// Bilet daha önce okutulmuşsa veya iptal ise başarısız olur.
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

  /// Tur katılımcılarına Firestore üzerinden duyuru + bildirim gönderir.
  Future<void> sendNotificationToParticipants(String tourId, String message) async {
    try {
      isLoading.value = true;
      final announcement = AnnouncementModel(
        id: '',
        notification: message,
        createdAt: DateTime.now(),
      );
      await _firebaseService.createAnnouncement(tourId, announcement);
      Get.snackbar(
        "Başarılı",
        "Duyuru kaydedildi. Bildirimler QR okutan katılımcılara sunucudan gönderilecek.",
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

  /// Tur bitirme talebi oluşturur ve 2 saniye sonra gösterge paneline yönlendirir.
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      isLoading.value = true;
      await _firebaseService.requestTourCompletion(tourId: tourId, guideId: guideId);

      Get.snackbar(
        "Başarılı",
        "Talep admin onayına gönderildi.",
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
        "Tur bitirme talebi oluşturulamadı: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
