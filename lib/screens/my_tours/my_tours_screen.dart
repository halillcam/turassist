import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/app_routes.dart';
import '../../config/colors.dart';
import '../../controllers/my_tours_controller.dart';
import '../../models/ticket_model.dart';
import '../../models/tour_model.dart';
import '../../models/tour_program_model.dart';
import '../../widgets/index.dart';

/// Turlarım ekranı - kullanıcının biletlerini ve aktif turlarını gösterir.
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
        Get.offNamed(AppRoutes.profile);
        break;
    }
  }

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

          // checked_in durumu → Aktif Tur Detayları ekranı
          if (controller.hasCheckedIn && controller.activeTour.value != null) {
            return _ActiveTourDetailView(controller: controller);
          }

          // Normal durum → Bilet listesi
          return _TicketListView(controller: controller);
        }),
      ),
      bottomNavigationBar: BottomNavBar(activeIndex: 1, onItemTapped: _onItemTapped),
      floatingActionButton: Obx(() {
        if (!controller.hasCheckedIn) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: controller.backToTicketList,
          backgroundColor: AppColors.slate700,
          icon: const Icon(Icons.undo, color: Colors.white, size: 20),
          label: const Text(
            'Listeye Dön',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Bilet Listesi Görünümü (QR taranmadan önce)
// ══════════════════════════════════════════════════════════════
class _TicketListView extends StatelessWidget {
  final MyToursController controller;
  const _TicketListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: Obx(() {
            final list = controller.selectedTab.value == 0
                ? controller.upcomingTickets
                : controller.pastTickets;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.selectedTab.value == 0
                          ? Icons.confirmation_number_outlined
                          : Icons.history,
                      color: AppColors.slate500,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.selectedTab.value == 0
                          ? 'Yaklaşan turunuz bulunmuyor.'
                          : 'Geçmiş turunuz bulunmuyor.',
                      style: const TextStyle(color: AppColors.slate400, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.primary,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = list[index];
                  final tour = controller.ticketTours[ticket.tourId];
                  return _buildTicketCard(context, ticket, tour);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            splashRadius: 24,
          ),
          const Expanded(
            child: Text(
              'Turlarım',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: AppColors.primary, size: 22),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(
      () => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
        ),
        child: Row(children: [_buildTab('Yaklaşan Turlar', 0), _buildTab('Geçmiş Turlar', 1)]),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketModel ticket, TourModel? tour) {
    final dateStr = DateFormat('dd MMMM yyyy', 'tr_TR').format(ticket.purchaseDate);
    final tourTitle = tour?.title ?? 'Tur';
    final companyName = tour?.guideName ?? '—';
    final isActive = ticket.status == 'active';

    return GestureDetector(
      onTap: isActive
          ? () {
              Get.toNamed(AppRoutes.myQrs, arguments: {'ticket': ticket, 'tourTitle': tourTitle});
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? AppColors.slate700 : AppColors.slate800),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tourTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tur ID: ${ticket.tourId}',
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: AppColors.slate300, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isActive)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'QR Göster',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showCancelDialog(context, ticket),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Turu İptal Et',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Future<void> _showCancelDialog(BuildContext context, TicketModel ticket) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text('Turu İptal Et', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bu turu iptal etmek istediğinize emin misiniz?',
            style: TextStyle(color: AppColors.slate300),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Evet, İptal Et', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await controller.cancelUpcomingTicket(ticket);
    }
  }
}

// ══════════════════════════════════════════════════════════════
// Aktif Tur Detayları Görünümü (QR tarandıktan sonra)
// ══════════════════════════════════════════════════════════════
class _ActiveTourDetailView extends StatelessWidget {
  final MyToursController controller;
  const _ActiveTourDetailView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tour = controller.activeTour.value;
      if (tour == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      final program = controller.programDays;

      return Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatusBadge(),
                    const SizedBox(height: 12),
                    _buildTourTitle(tour.title),
                    const SizedBox(height: 24),
                    _buildVehicleCard(tour.busInfo.plate),
                    const SizedBox(height: 12),
                    _buildGuideCard(tour.guideName ?? 'Rehber', tour.busInfo.phoneNumber),
                    const SizedBox(height: 12),
                    _buildAnnouncementsCard(tour.id, tour.title),
                    const SizedBox(height: 12),
                    _buildChatCard(tour.id, tour.title),
                    const SizedBox(height: 28),
                    if (program.isNotEmpty) _buildProgramSection(program, tour.createdAt),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            splashRadius: 24,
          ),
          const Expanded(
            child: Text(
              'Aktif Tur Detayları',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: AppColors.primary, size: 22),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
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
    );
  }

  Widget _buildTourTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }

  Widget _buildVehicleCard(String plate) {
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
            child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Araç Plakası',
                style: TextStyle(
                  color: AppColors.slate400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                plate.isNotEmpty ? plate : '—',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String guideName, String phone) {
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
            child: const Icon(Icons.account_circle, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tur Sorumlusu',
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  guideName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Aranıyor',
                  phone,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  /// Tur sohbetine erişim kartı.
  Widget _buildChatCard(String tourId, String tourTitle) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.chat, arguments: {'tourId': tourId, 'tourTitle': tourTitle}),
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
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tur Sohbeti',
                    style: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Grup sohbetine katıl',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
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

  /// Tur duyurularına erişim kartı.
  Widget _buildAnnouncementsCard(String tourId, String tourTitle) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.tourAnnouncements,
        arguments: {'tourId': tourId, 'tourTitle': tourTitle},
      ),
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
                color: AppColors.warning.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.campaign_outlined, color: AppColors.warning, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tur Duyuruları',
                    style: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Geçmiş bildirimleri görüntüle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withOpacity(0.3),
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

  Widget _buildProgramSection(List<TourProgramDay> programDays, DateTime tourDate) {
    final dateStr = DateFormat('d MMMM yyyy', 'tr_TR').format(tourDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tur Programı',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              dateStr,
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...programDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isLast = index == programDays.length - 1;

          _TimelineStatus status;
          if (index < programDays.length ~/ 2) {
            status = _TimelineStatus.completed;
          } else if (index == programDays.length ~/ 2) {
            status = _TimelineStatus.active;
          } else {
            status = _TimelineStatus.upcoming;
          }

          return _buildTimelineItem(
            title: day.title,
            activities: day.activities,
            order: day.order,
            status: status,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required List<String> activities,
    required int order,
    required _TimelineStatus status,
    required bool isLast,
  }) {
    final isActive = status == _TimelineStatus.active;
    final isCompleted = status == _TimelineStatus.completed;
    final isUpcoming = status == _TimelineStatus.upcoming;

    Color dotBorderColor;
    Color dotFillColor;
    Color dotInnerColor;
    if (isActive) {
      dotBorderColor = AppColors.primary;
      dotFillColor = AppColors.primary;
      dotInnerColor = Colors.white;
    } else if (isCompleted) {
      dotBorderColor = AppColors.primary;
      dotFillColor = AppColors.backgroundDark;
      dotInnerColor = AppColors.primary;
    } else {
      dotBorderColor = AppColors.slate700;
      dotFillColor = AppColors.backgroundDark;
      dotInnerColor = AppColors.slate700;
    }

    final titleColor = isActive
        ? AppColors.primary
        : isUpcoming
        ? AppColors.slate300
        : Colors.white;
    final descColor = isUpcoming ? AppColors.slate500 : AppColors.slate400;
    final timeBgColor = isActive ? AppColors.primary.withOpacity(0.2) : AppColors.slate800;
    final timeTextColor = isActive ? AppColors.primary : AppColors.slate400;
    final orderText = '${order.toString().padLeft(2, '0')}:00';
    final description = activities.isNotEmpty ? activities.join('\n') : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: dotFillColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotBorderColor, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: dotInnerColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              if (!isLast) Container(width: 2, height: 72, color: AppColors.slate800),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: timeBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        orderText,
                        style: TextStyle(
                          color: timeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: descColor,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _TimelineStatus { completed, active, upcoming }
