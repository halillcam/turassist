import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/announcement_model.dart';

class AnnouncementController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var announcements = <AnnouncementModel>[].obs;
  var isLoading = false.obs;

  // Tura ait duyuruları anlık dinle [cite: 25]
  void listenAnnouncements(String tourId) {
    _firebaseService.getAnnouncements(tourId).listen((data) {
      announcements.assignAll(data);
    });
  }

  // Rehber/Admin duyuru gönderir [cite: 25, 38]
  Future<void> postAnnouncement(String tourId, String msg) async {
    try {
      isLoading.value = true;
      final newAnn = AnnouncementModel(id: '', notification: msg, createdAt: DateTime.now());
      await _firebaseService.createAnnouncement(tourId, newAnn);
      Get.snackbar(
        "Başarılı",
        "Duyuru gönderildi.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Duyuru gönderme başarısız: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Tüm duyuruları yükle [cite: 25]
  Future<void> fetchAllAnnouncements(String tourId) async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getAllAnnouncements(tourId);
      announcements.assignAll(result);
    } catch (e) {
      print('Duyuruları yüklerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Duyuru sil [cite: 25, 38]
  Future<void> deleteAnnouncement(String tourId, String announcementId) async {
    try {
      isLoading.value = true;
      await _firebaseService.deleteAnnouncement(tourId, announcementId);
      announcements.removeWhere((a) => a.id == announcementId);
      Get.snackbar(
        "Başarılı",
        "Duyuru silindi.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Duyuru silme başarısız: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
