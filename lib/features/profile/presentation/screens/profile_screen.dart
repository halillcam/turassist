import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../../widgets/bottom_nav_bar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_guest_view.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_card.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.offNamed(AppRoutes.tourList),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!controller.isLoggedIn) {
          return const ProfileGuestView();
        }

        final user = controller.user.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              ProfileHeader(initials: controller.getInitials(), user: user),
              const SizedBox(height: 32),
              if (!controller.isSyntheticUser) ...[
                ProfileMenuCard(
                  showPasswordAction: !controller.isGoogleOnlyUser,
                  notificationsEnabled: controller.notificationsEnabled.value,
                  onEditProfile: () async {
                    final result = await Get.to(
                      () => const EditProfileScreen(),
                      arguments: {'fullName': user?.fullName ?? '', 'email': user?.email ?? ''},
                    );
                    if (result == true) {
                      await controller.loadUserProfile();
                    }
                  },
                  onChangePassword: () => Get.to(() => const ChangePasswordScreen()),
                  onToggleNotifications: (value) => controller.notificationsEnabled.value = value,
                ),
              ],
              const SizedBox(height: 24),
              ProfileLogoutButton(onLogout: controller.logout),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavBar(
        activeIndex: 2,
        onItemTapped: (index) {
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
        },
        hideHome: controller.isSyntheticUser,
      ),
    );
  }
}
