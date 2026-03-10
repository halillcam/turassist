import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/tour_model.dart';
import '../controllers/my_tours_controller.dart';

class TicketListView extends StatelessWidget {
  const TicketListView({super.key, required this.controller});

  final MyToursController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'Turlarım',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              _TabButton(
                label: 'Yaklaşan Turlar',
                isActive: controller.selectedTab.value == 0,
                onTap: () => controller.selectedTab.value = 0,
              ),
              _TabButton(
                label: 'Geçmiş Turlar',
                isActive: controller.selectedTab.value == 1,
                onTap: () => controller.selectedTab.value = 1,
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = controller.selectedTab.value == 0
                ? controller.upcomingTickets
                : controller.pastTickets;
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'Gösterilecek tur bulunmuyor.',
                  style: TextStyle(color: AppColors.slate400),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadData,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _TicketCard(
                  ticket: list[index],
                  tour: controller.ticketTours[list[index].tourId],
                  controller: controller,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.slate500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.tour, required this.controller});

  final TicketModel ticket;
  final TourModel? tour;
  final MyToursController controller;

  @override
  Widget build(BuildContext context) {
    final purchaseDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(ticket.purchaseDate);
    final departure = ticket.departureDate == null
        ? null
        : DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(ticket.departureDate!);
    final isActive = ticket.status == 'active';
    return GestureDetector(
      onTap: isActive
          ? () => Get.toNamed(
              AppRoutes.myQrs,
              arguments: {'ticket': ticket, 'tourTitle': tour?.title ?? 'Tur'},
            )
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate700),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour?.title ?? 'Tur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (departure != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Çıkış: $departure',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Satın alım: $purchaseDate',
                    style: const TextStyle(color: AppColors.slate300, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isActive)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'QR Göster',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final success = await controller.cancelUpcomingTicket(ticket);
                      Get.snackbar(
                        success ? 'İptal Edildi' : 'Hata',
                        success
                            ? 'Tur başarıyla iptal edildi.'
                            : 'Tur iptal işlemi başarısız oldu.',
                      );
                    },
                    child: const Text(
                      'Turu İptal Et',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.qr_code_2, color: AppColors.slate500, size: 40),
          ],
        ),
      ),
    );
  }
}
