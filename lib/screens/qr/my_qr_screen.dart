import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/widgets/index.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

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
      bottomNavigationBar: BottomNavBar(activeIndex: 2, onItemTapped: _onItemTapped),
    );
  }
}
