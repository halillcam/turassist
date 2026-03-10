import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../controllers/my_tours_controller.dart';

class ActiveTourDetailView extends StatelessWidget {
  const ActiveTourDetailView({super.key, required this.controller});

  final MyToursController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tour = controller.activeTour.value;
      if (tour == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      final program = controller.programDays;

      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Aktif Tur Detayları',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'TUR AKTİF',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tour.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _InfoTile(title: 'Araç Plakası', value: tour.busInfo.plate, icon: Icons.directions_bus),
            const SizedBox(height: 12),
            _InfoTile(
              title: 'Tur Sorumlusu',
              value: tour.guideName ?? 'Rehber',
              subtitle: tour.busInfo.phoneNumber,
              icon: Icons.account_circle,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: 'Tur Duyuruları',
              subtitle: 'Geçmiş bildirimleri görüntüle',
              icon: Icons.campaign_outlined,
              iconColor: AppColors.warning,
              actionColor: AppColors.warning,
              onTap: () => Get.toNamed(
                AppRoutes.tourAnnouncements,
                arguments: {'tourId': tour.id, 'tourTitle': tour.title},
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: 'Tur Sohbeti',
              subtitle: 'Grup sohbetine katıl',
              icon: Icons.chat_bubble_outline,
              iconColor: AppColors.success,
              actionColor: AppColors.success,
              onTap: () => Get.toNamed(
                AppRoutes.chat,
                arguments: {'tourId': tour.id, 'tourTitle': tour.title},
              ),
            ),
            if (program.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tur Programı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(tour.createdAt),
                    style: const TextStyle(color: AppColors.slate400),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...program.map(
                (day) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...day.activities.map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activity,
                                  style: const TextStyle(color: AppColors.slate400, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value, required this.icon, this.subtitle});

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate800),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(color: AppColors.slate400, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.actionColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate800),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: const TextStyle(color: AppColors.slate400)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: actionColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
