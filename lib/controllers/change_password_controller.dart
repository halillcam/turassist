import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/colors.dart';

/// Şifre değiştirme ekranı controller'ı.
///
/// Mevcut şifre ile yeniden doğrulama ve yeni şifre güncelleme
/// işlemlerini yönetir.
class ChangePasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Şifreyi doğrulayıp günceller.
  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Tüm alanları doldurunuz');
      return;
    }

    if (newPassword.length < 6) {
      _showError('Yeni şifre en az 6 karakter olmalıdır');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Yeni şifreler eşleşmiyor');
      return;
    }

    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Mevcut şifre ile yeniden doğrulama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Başarılı',
        'Şifreniz başarıyla güncellendi',
        backgroundColor: AppColors.primary.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' => 'Mevcut şifreniz hatalı',
        'weak-password' => 'Yeni şifre çok zayıf',
        'requires-recent-login' => 'Lütfen yeniden giriş yapınız',
        _ => 'Bir hata oluştu',
      };
      _showError(message);
    } catch (e) {
      _showError('Şifre değiştirilirken bir hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      backgroundColor: AppColors.error.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
