import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import 'nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onItemTapped;
  final Map<int, String?>? badges;

  /// true ise Anasayfa sekmesi gizlenir (sentetik domain kullanıcıları için)
  final bool hideHome;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onItemTapped,
    this.badges,
    this.hideHome = false,
  });

  void _handleTap(int index) {
    if (index == activeIndex) return;
    if (Get.isOverlaysOpen) {
      Get.closeAllSnackbars();
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    }
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.9),
        border: Border(top: BorderSide(color: AppColors.slate800, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!hideHome)
                Expanded(
                  child: NavItem(
                    icon: Icons.home,
                    label: 'Anasayfa',
                    isActive: activeIndex == 0,
                    badge: badges?[0],
                    onTap: () => _handleTap(0),
                  ),
                ),
              Expanded(
                child: NavItem(
                  icon: Icons.confirmation_number,
                  label: 'Turlarım',
                  isActive: activeIndex == 1,
                  badge: badges?[1],
                  onTap: () => _handleTap(1),
                ),
              ),
              Expanded(
                child: NavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  isActive: activeIndex == 2,
                  badge: badges?[2],
                  onTap: () => _handleTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
