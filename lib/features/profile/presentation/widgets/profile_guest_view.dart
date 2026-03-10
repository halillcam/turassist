import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';

class ProfileGuestView extends StatelessWidget {
  const ProfileGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.slate800,
                border: Border.all(color: AppColors.slate700, width: 2),
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.slate500, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz giriş yapmadınız',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Profilinizi görüntülemek, turlarınızı takip etmek ve daha fazlası için giriş yapın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate400, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.login),
                icon: const Icon(Icons.login_rounded, color: Colors.white),
                label: const Text(
                  'Giriş Yap',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.signup),
                icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
                label: const Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
