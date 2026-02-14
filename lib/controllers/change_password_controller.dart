import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';

/// Şifre değiştirme controller'ı.
///
/// Mevcut şifre ile yeniden doğrulama (reauthentication) yaparak
/// yeni şifre güncelleme işlemini yönetir.
///
/// Doğrulama kuralları:
/// - Tüm alanlar dolu olmalı
/// - Yeni şifre en az 6 karakter
/// - Yeni şifre onayı eşleşmeli
/// - Yeni şifre mevcut şifreden farklı olmalı
/// - Google-only kullanıcılar şifre değiştiremez
class ChangePasswordController extends GetxController {
  // ─── Text Controller'ları ───
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ─── Reactive State ───
  final RxBool isLoading = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  // ─── Lifecycle ───

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ─── Şifre Değiştirme ───

  /// Mevcut şifreyi doğrular ve yeni şifreye günceller.
  ///
  /// İş akışı:
  /// 1. Form alanlarını doğrula (boşluk, uzunluk, eşleşme, farklılık)
  /// 2. Google-only kullanıcı kontrolü
  /// 3. Mevcut şifre ile reauthentication
  /// 4. Yeni şifreyi Firebase'e kaydet
  /// 5. Başarılıysa profil ekranına yönlendir
  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ── Validasyonlar ──
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
    if (currentPassword == newPassword) {
      _showError('Yeni şifre mevcut şifre ile aynı olamaz');
      return;
    }

    // ── Firebase İşlemleri ──
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Google-only kullanıcılar şifre ile giriş yapmadığı için değiştiremez
      final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
      final hasPasswordProvider = user.providerData.any((info) => info.providerId == 'password');

      if (isGoogleUser && !hasPasswordProvider) {
        _showError('Google ile giriş yaptığınız için şifre değiştiremezsiniz');
        return;
      }

      // Mevcut şifre ile yeniden doğrulama
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(newPassword);

      _showSuccess('Şifreniz başarıyla güncellendi.');
      Get.offAllNamed('/profile');
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseErrorToTurkish(e.code));
    } catch (e) {
      _showError('Şifre değiştirilirken bir sorun oluştu. Lütfen tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Yardımcı Metotlar ───

  /// Firebase Auth hata kodlarını Türkçe mesajlara çevirir.
  String _firebaseErrorToTurkish(String code) {
    return switch (code) {
      'wrong-password' || 'invalid-credential' => 'Mevcut şifreniz hatalı. Lütfen tekrar deneyin.',
      'weak-password' => 'Yeni şifre çok zayıf. En az 6 karakter kullanın.',
      'requires-recent-login' => 'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor.',
      'too-many-requests' => 'Çok fazla deneme yapıldı. Lütfen birkaç dakika sonra tekrar deneyin.',
      'network-request-failed' => 'İnternet bağlantınızı kontrol edin.',
      _ => 'Bir hata oluştu. Lütfen tekrar deneyin.',
    };
  }

  /// Başarı snackbar'ı gösterir.
  void _showSuccess(String message) {
    Get.snackbar(
      'İşlem Başarılı',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Hata snackbar'ı gösterir.
  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
