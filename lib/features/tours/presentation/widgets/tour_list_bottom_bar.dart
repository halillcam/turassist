import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../widgets/bottom_nav_bar.dart';

class TourListBottomBar extends StatelessWidget {
  const TourListBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(
      activeIndex: 0,
      onItemTapped: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Get.offNamed(AppRoutes.myTours);
            break;
          case 2:
            Get.offNamed(AppRoutes.profile);
            break;
        }
      },
    );
  }
}
