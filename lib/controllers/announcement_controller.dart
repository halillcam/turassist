import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';

/// Tura ait duyuruları yöneten controller.
///
/// Sorumlulukları:
/// - Duyuruları Firestore stream ile anlık dinleme
/// - Müşteri tarafı fallback: izin hatasında `/users/{uid}/notifications`
///   koleksiyonundan duyuruları dinler
/// - Duyuru oluşturma (rehber) ve silme (rehber/admin)
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

  /// Tura ait duyuruları Firestore stream ile anlık dinlemeye başlar.
  ///
  /// Firestore izin hatası alınırsa müşteri bildirimleri fallback'ine geçer.
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

  /// Firestore 'announcements' koleksiyonu okuma izni yoksa
  /// müşterinin kendi bildirim koleksiyonundan fallback olarak dinler.
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

  /// Rehber / Admin yeni duyuru oluşturur ve katılımcılara bildirim gönderir.
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

  /// Duyuru oluşturur; bildirimler sunucu tarafından yalnızca
  /// QR okutan katılımcılara (`checked_in`) iletilir.
  Future<void> postAnnouncementForCheckedInParticipants(String tourId, String msg) async {
    try {
      isLoading.value = true;
      final newAnn = AnnouncementModel(id: '', notification: msg, createdAt: DateTime.now());
      await _firebaseService.createAnnouncement(tourId, newAnn);
      Get.snackbar(
        "Başarılı",
        "Duyuru gönderildi. Bildirimler sunucu tarafından QR okutan katılımcılara iletilecek.",
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

  /// Tüm geçmiş duyuruları tek seferlik getirir.
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

  /// Belirtilen duyuruyu siler ve lokal listeden kaldırır.
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
