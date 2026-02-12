import 'package:flutter/material.dart';
import 'package:turassist/config/colors.dart';
import 'nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onItemTapped;
  final Map<int, String?>? badges;

  const BottomNavBar({Key? key, required this.activeIndex, required this.onItemTapped, this.badges})
    : super(key: key);

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
              NavItem(
                icon: Icons.home,
                label: 'Anasayfa',
                isActive: activeIndex == 0,
                badge: badges?[0],
                onTap: () => onItemTapped(0),
              ),
              NavItem(
                icon: Icons.confirmation_number,
                label: 'Turlarım',
                isActive: activeIndex == 1,
                badge: badges?[1],
                onTap: () => onItemTapped(1),
              ),
              NavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                isActive: activeIndex == 2,
                badge: badges?[2],
                onTap: () => onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
