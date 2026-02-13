import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/colors.dart';

/// Profil düzenleme ekranı controller'ı.
///
/// Kullanıcı adı ve e-posta güncellemelerini yönetir.
class EditProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, String>?;
    if (args != null) {
      fullNameController.text = args['fullName'] ?? '';
      emailController.text = args['email'] ?? '';
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// Kullanıcı bilgilerini FirebaseAuth ve Firestore'da günceller.
  Future<void> updateProfile() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showError('Ad Soyad ve E-posta alanları boş bırakılamaz');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Geçerli bir e-posta adresi giriniz');
      return;
    }

    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı bulunamadı');

      // E-posta değiştiyse doğrulama e-postası gönder
      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      // Firestore'da güncelle
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': name,
        'email': email,
      });

      Get.snackbar(
        'Başarılı',
        'Profil bilgileriniz güncellendi',
        backgroundColor: AppColors.primary.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.back(result: true);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'requires-recent-login' => 'E-posta değişikliği için yeniden giriş yapmanız gerekiyor',
        'email-already-in-use' => 'Bu e-posta adresi zaten kullanılıyor',
        _ => 'Bir hata oluştu',
      };
      _showError(message);
    } catch (e) {
      _showError('Profil güncellenirken bir hata oluştu');
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
