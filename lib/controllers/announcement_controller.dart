import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';

class AnnouncementController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  var announcements = <AnnouncementModel>[].obs;
  var isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  StreamSubscription<List<AnnouncementModel>>? _subscription;

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // Tura ait duyuruları anlık dinle [cite: 25]
  void listenAnnouncements(String tourId) {
    _subscription?.cancel();
    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _firebaseService
        .getAnnouncements(tourId)
        .listen(
          (data) {
            announcements.assignAll(data);
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (e) {
            final msg = e.toString().toLowerCase();
            if (msg.contains('permission_denied') ||
                msg.contains('missing or insufficient permissions')) {
              errorMessage.value =
                  'Duyuruları görüntülemek için Firestore okuma yetkisi yok. Lütfen güvenlik kurallarını kontrol edin.';

              // Customer tarafında fallback: kendi notifications altından geçmiş duyuruları göster.
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              if (uid.isNotEmpty) {
                _listenUserNotificationsFallback(uid, tourId);
                return;
              }
            } else {
              errorMessage.value = 'Duyurular yüklenemedi: $e';
            }
            announcements.clear();
            isLoading.value = false;
          },
        );
  }

  void _listenUserNotificationsFallback(String userId, String tourId) {
    _subscription?.cancel();
    _subscription = _firebaseService
        .getUserTourNotifications(userId, tourId)
        .listen(
          (data) {
            announcements.assignAll(data);
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            errorMessage.value = 'Duyurular yüklenemedi: $e';
          },
        );
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
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Duyuru gönderme başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rehber duyuruyu gönderir ve sadece QR okutan katılımcılara bildirim düşer.
  Future<void> postAnnouncementForCheckedInParticipants(String tourId, String msg) async {
    try {
      isLoading.value = true;
      final newAnn = AnnouncementModel(id: '', notification: msg, createdAt: DateTime.now());
      await _firebaseService.createAnnouncement(tourId, newAnn);
      await _firebaseService.sendNotificationToTourParticipants(tourId, msg);
      Get.snackbar(
        "Başarılı",
        "Duyuru gönderildi. Yalnızca QR okutan katılımcılar görebilir.",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Duyuru gönderme başarısız: $e",
        backgroundColor: AppColors.error,
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
      debugPrint('Duyuruları yüklerken hata: $e');
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
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Duyuru silme başarısız: $e",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
