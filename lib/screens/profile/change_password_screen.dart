import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turassist/config/colors.dart';

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

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Hata',
        'Tüm alanları doldurunuz',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Hata',
        'Yeni şifre en az 6 karakter olmalıdır',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Hata',
        'Yeni şifreler eşleşmiyor',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception('Kullanıcı bulunamadı');

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
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
      String message = 'Bir hata oluştu';
      if (e.code == 'wrong-password') {
        message = 'Mevcut şifreniz hatalı';
      } else if (e.code == 'weak-password') {
        message = 'Yeni şifre çok zayıf';
      } else if (e.code == 'requires-recent-login') {
        message = 'Lütfen yeniden giriş yapınız';
      }
      Get.snackbar(
        'Hata',
        message,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Şifre değiştirilirken bir hata oluştu',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF0d5bab)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 32),

            // Current Password
            _buildLabel('Mevcut Şifre'),
            const SizedBox(height: 8),
            Obx(
              () => _buildPasswordField(
                controller: controller.currentPasswordController,
                hint: 'Mevcut şifrenizi girin',
                isObscured: !controller.showCurrentPassword.value,
                onToggle: () =>
                    controller.showCurrentPassword.value = !controller.showCurrentPassword.value,
              ),
            ),
            const SizedBox(height: 20),

            // New Password
            _buildLabel('Yeni Şifre'),
            const SizedBox(height: 8),
            Obx(
              () => _buildPasswordField(
                controller: controller.newPasswordController,
                hint: 'Yeni şifrenizi girin',
                isObscured: !controller.showNewPassword.value,
                onToggle: () =>
                    controller.showNewPassword.value = !controller.showNewPassword.value,
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Password
            _buildLabel('Yeni Şifre (Tekrar)'),
            const SizedBox(height: 8),
            Obx(
              () => _buildPasswordField(
                controller: controller.confirmPasswordController,
                hint: 'Yeni şifrenizi tekrar girin',
                isObscured: !controller.showConfirmPassword.value,
                onToggle: () =>
                    controller.showConfirmPassword.value = !controller.showConfirmPassword.value,
              ),
            ),
            const SizedBox(height: 36),

            // Update Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Güncelle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.slate400, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate700.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.slate500.withOpacity(0.7)),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.slate500,
              size: 22,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
