import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';
import '../config/colors.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

/// Profil ekranı için kullanıcı bilgilerini yöneten controller.
class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  /// Firestore'dan kullanıcı profilini yükler.
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    user.value = await _firebaseService.getUserProfile();
    isLoading.value = false;
  }

  /// Kullanıcı adının baş harflerini döndürür (avatar için).
  String getInitials() {
    final name = user.value?.fullName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  /// Kullanıcıyı çıkış yaptırır ve giriş ekranına yönlendirir.
  Future<void> logout() async {
    try {
      await _firebaseService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Çıkış yapılırken bir hata oluştu',
        backgroundColor: AppColors.error.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
