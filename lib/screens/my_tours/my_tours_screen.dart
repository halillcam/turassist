import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/widgets/index.dart';

class MyToursScreen extends StatelessWidget {
  const MyToursScreen({super.key});

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.tourList);
        break;
      case 1:
        break;
      case 2:
        Get.offNamed(AppRoutes.myQrs);
        break;
      case 3:
        Get.offNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: const SafeArea(child: SizedBox.shrink()),
      bottomNavigationBar: BottomNavBar(activeIndex: 1, onItemTapped: _onItemTapped),
    );
  }
}
