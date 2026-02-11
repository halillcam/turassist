import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/widgets/index.dart';

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
        Get.offNamed(AppRoutes.myQrs);
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: const SafeArea(child: SizedBox.shrink()),
      bottomNavigationBar: BottomNavBar(activeIndex: 3, onItemTapped: _onItemTapped),
    );
  }
}
