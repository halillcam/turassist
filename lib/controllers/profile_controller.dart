import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';
import '../config/colors.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/google_auth_service.dart';

/// Profil ekranı için kullanıcı bilgilerini yöneten controller.
class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool notificationsEnabled = true.obs;

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  /// Kullanıcı sadece Google ile mi giriş yapmış? (şifre değiştirme gizlenir)
  bool get isGoogleOnlyUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    final hasPassword = user.providerData.any((p) => p.providerId == 'password');
    return isGoogle && !hasPassword;
  }

  /// Sentetik domain ile giriş yapmış mı?
  /// Bu kullanıcılar profil düzenleyemez, ana sayfa görmez.
  ///   *@guide.turassist    → guide hesapları
  ///   *@customer.turassist → fiziksel satış müşteri hesapları
  bool get isSyntheticUser {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return email.endsWith('@guide.turassist') || email.endsWith('@customer.turassist');
  }

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  /// Firestore'dan kullanıcı profilini yükler.
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    if (isLoggedIn) {
      user.value = await _firebaseService.getUserProfile();
    } else {
      user.value = null;
    }
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

  /// Kullanıcıyı çıkış yaptırır ve tur listesine geri döner.
  Future<void> logout() async {
    try {
      await _googleAuthService.signOut();
      user.value = null;
      Get.offAllNamed(AppRoutes.tourList);
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
