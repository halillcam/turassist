import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_routes.dart';
import '../../config/colors.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/index.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.tourList);
        break;
      case 1:
        Get.offNamed(AppRoutes.myTours);
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.offNamed(AppRoutes.tourList),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // Giriş yapılmamışsa guest profil göster
        if (!controller.isLoggedIn) {
          return _buildGuestView();
        }

        final user = controller.user.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar & User Info
              _buildProfileHeader(controller, user),
              const SizedBox(height: 32),

              // Menu Items
              _buildMenuCard(controller),
              const SizedBox(height: 24),

              // Logout Button
              _buildLogoutButton(controller),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavBar(activeIndex: 2, onItemTapped: _onItemTapped),
    );
  }

  /// Giriş yapılmamış kullanıcılar için görünüm.
  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar placeholder
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

            Text(
              'Profilinizi görüntülemek, turlarınızı takip etmek ve daha fazlası için giriş yapın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate400, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Giriş Yap Butonu
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
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kayıt Ol Butonu
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

  Widget _buildProfileHeader(ProfileController controller, UserModel? user) {
    return Column(
      children: [
        // Avatar with initials
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              controller.getInitials(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          user?.fullName ?? 'Kullanıcı',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),

        // Email
        Text(user?.email ?? '', style: const TextStyle(color: AppColors.slate400, fontSize: 14)),

        // Phone
        if (user?.phone != null && user!.phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(user.phone, style: const TextStyle(color: AppColors.slate500, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildMenuCard(ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Profili Düzenle',
            onTap: () async {
              final user = controller.user.value;
              final result = await Get.to(
                () => const EditProfileScreen(),
                arguments: {'fullName': user?.fullName ?? '', 'email': user?.email ?? ''},
                transition: Transition.rightToLeft,
              );
              if (result == true) {
                controller.loadUserProfile();
              }
            },
          ),
          _buildDivider(),
          if (!controller.isGoogleOnlyUser)
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Şifre Değiştir',
              onTap: () {
                Get.to(() => const ChangePasswordScreen(), transition: Transition.rightToLeft);
              },
            ),
          if (!controller.isGoogleOnlyUser) _buildDivider(),
          _buildNotificationItem(controller),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(ProfileController controller) {
    return Obx(() {
      final enabled = controller.notificationsEnabled.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.notificationsEnabled.value = !enabled;
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (enabled ? AppColors.primary : AppColors.slate600).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                    color: enabled ? AppColors.primary : AppColors.slate500,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bildirimler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled ? 'Bildirimler açık' : 'Bildirimler kapalı',
                        style: TextStyle(
                          color: enabled ? AppColors.primary : AppColors.slate500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (val) {
                    controller.notificationsEnabled.value = val;
                  },
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                  inactiveThumbColor: AppColors.slate500,
                  inactiveTrackColor: AppColors.slate700,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.slate500, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: AppColors.slate700.withOpacity(0.4)),
    );
  }

  Widget _buildLogoutButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.defaultDialog(
              title: 'Çıkış Yap',
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              middleText: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
              middleTextStyle: const TextStyle(color: AppColors.slate400),
              backgroundColor: AppColors.cardDark,
              confirm: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Get.back();
                  controller.logout();
                },
                child: const Text('Çıkış Yap'),
              ),
              cancel: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate400,
                  side: const BorderSide(color: AppColors.slate600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: Get.back,
                child: const Text('İptal'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                SizedBox(width: 10),
                Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
