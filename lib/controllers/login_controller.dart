import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class LoginController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var isLoading = false.obs;
  var obscureText = true.obs;

  // Giriş Yap ve Yönlendir
  Future<void> login(String email, String password, String companyId) async {
    try {
      isLoading.value = true;

      // 1. Firebase Service üzerinden giriş ve yetki kontrolü yap
      UserModel? user = await _firebaseService.loginAndCheckAuth(email, password, companyId);

      if (user != null) {
        _navigateBasedOnRole(user);
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        e.toString().replaceAll("Exception:", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rol bazlı yönlendirme mantığı
  void _navigateBasedOnRole(UserModel user) {
    // Mobile App'te SADECE customer, guest, guide olabilir
    // Admin ve Super Admin web panel'de (ayrı proje) [cite: 40, 42]
    switch (user.role) {
      case 'customer':
        Get.offAllNamed('/city-selection'); // Müşteri şehir seçimine
        break;
      case 'guest':
        Get.offAllNamed('/city-selection'); // Misafir şehir seçimine
        break;
      case 'guide':
        Get.offAllNamed('/guide-dashboard'); // Tur Sorumlusu paneline
        break;
      default:
        // Admin/Super Admin bu app'te kullanılamaz
        Get.snackbar(
          "Hata",
          "Bu hesap mobile app'te kullanılamaz. Web admin panelini kullanınız.",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
    }
  }

  // Tur Sorumlusu Girişi [cite: 18, 21]
  Future<void> guideLogin(String guideId, String password) async {
    try {
      isLoading.value = true;

      UserModel? user = await _firebaseService.guideLogin(guideId, password);

      if (user != null) {
        Get.snackbar(
          "Başarılı",
          "Hoşgeldiniz ${user.fullName}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        _navigateBasedOnRole(user);
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        e.toString().replaceAll("Exception:", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  // Kayıt Ol [cite: 12]
  Future<void> register(String email, String password, String name, String surname) async {
    try {
      isLoading.value = true;

      // Firebase Service üzerinden kayıt işlemi yap
      UserModel? user = await _firebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );

      if (user != null) {
        Get.snackbar(
          "Başarılı",
          "Kayıt başarılı! Lütfen giriş yapınız.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar(
        "Hata",
        e.toString().replaceAll("Exception:", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Çıkış Yap [cite: 12]
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _firebaseService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        "Hata",
        "Çıkış işlemi başarısız: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Şifre Sıfırlama [cite: 12]
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _firebaseService.resetPassword(email);
      Get.snackbar(
        "Başarılı",
        "Şifre sıfırlama linki $email adresine gönderildi.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Hata",
        e.toString().replaceAll("Exception:", ""),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
