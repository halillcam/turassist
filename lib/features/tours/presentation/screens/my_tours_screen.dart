import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../../widgets/bottom_nav_bar.dart';
import '../controllers/my_tours_controller.dart';
import '../widgets/active_tour_detail_view.dart';
import '../widgets/ticket_list_view.dart';

class MyToursScreen extends StatelessWidget {
  const MyToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyToursController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (controller.hasCheckedIn) {
            return ActiveTourDetailView(controller: controller);
          }
          return TicketListView(controller: controller);
        }),
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: 1,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Get.offNamed(AppRoutes.tourList);
              break;
            case 1:
              break;
            case 2:
              Get.offNamed(AppRoutes.profile);
              break;
          }
        },
        hideHome: () {
          final email = FirebaseAuth.instance.currentUser?.email ?? '';
          return email.endsWith('@guide.turassist') || email.endsWith('@customer.turassist');
        }(),
      ),
    );
  }
}
