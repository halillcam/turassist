import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rol bazlı yönlendirme mantığı
  void _navigateBasedOnRole(UserModel user) {
    switch (user.role) {
      case 'super_admin':
      case 'admin':
        Get.offAllNamed('/admin-dashboard'); // Admin paneline
        break;
      case 'guide':
        Get.offAllNamed('/guide-dashboard'); // Rehber paneline
        break;
      case 'customer':
        Get.offAllNamed('/city-selection'); // Müşteri şehir seçimine
        break;
      default:
        Get.offAllNamed('/login');
    }
  }

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;
}
