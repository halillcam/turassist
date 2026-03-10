import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/profile_form_header.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Profili Düzenle', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileFormHeader(icon: Icons.person_outline_rounded),
            const SizedBox(height: 32),
            const Text(
              'Ad Soyad',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ProfileFormField(
              controller: controller.fullNameController,
              hint: 'Ad Soyad',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            const Text(
              'E-posta',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ProfileFormField(
              controller: controller.emailController,
              hint: 'E-posta adresiniz',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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
                            await controller.updateProfile();
                            Get.snackbar('Başarılı', 'Profil bilgileriniz güncellendi');
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
