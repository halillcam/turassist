import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/change_password_controller.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/profile_form_header.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Şifre Değiştir', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileFormHeader(icon: Icons.lock_outline_rounded),
            const SizedBox(height: 32),
            const Text(
              'Mevcut Şifre',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ProfileFormField(
                controller: controller.currentPasswordController,
                hint: 'Mevcut şifrenizi girin',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.showCurrentPassword.value,
                suffix: IconButton(
                  onPressed: () =>
                      controller.showCurrentPassword.value = !controller.showCurrentPassword.value,
                  icon: Icon(
                    controller.showCurrentPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yeni Şifre',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ProfileFormField(
                controller: controller.newPasswordController,
                hint: 'Yeni şifrenizi girin',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.showNewPassword.value,
                suffix: IconButton(
                  onPressed: () =>
                      controller.showNewPassword.value = !controller.showNewPassword.value,
                  icon: Icon(
                    controller.showNewPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yeni Şifre (Tekrar)',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ProfileFormField(
                controller: controller.confirmPasswordController,
                hint: 'Yeni şifrenizi tekrar girin',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.showConfirmPassword.value,
                suffix: IconButton(
                  onPressed: () =>
                      controller.showConfirmPassword.value = !controller.showConfirmPassword.value,
                  icon: Icon(
                    controller.showConfirmPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          try {
                            await controller.changePassword();
                            Get.snackbar('Başarılı', 'Şifreniz başarıyla güncellendi.');
                          } catch (error) {
                            Get.snackbar('Hata', error.toString().replaceFirst('Exception: ', ''));
                          }
                        },
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
}
