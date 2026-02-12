import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/models/ticket_model.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/models/tour_program_model.dart';
import 'package:turassist/services/firebase_service.dart';
import 'package:turassist/widgets/index.dart';

// ── Controller ──────────────────────────────────────────────
class MyToursController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  // Genel durum
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Bilet listesi (QR taranmamış)
  var tickets = <TicketModel>[].obs;
  var ticketTours = <String, TourModel>{}.obs; // tourId -> TourModel cache
  var selectedTab = 0.obs; // 0: Yaklaşan, 1: Geçmiş

  // Aktif tur detayı (QR taranmış - checked_in)
  var checkedInTicket = Rxn<TicketModel>();
  var activeTour = Rxn<TourModel>();
  var programDays = <TourProgramDay>[].obs;

  // Test modu
  var isTestCheckedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Kullanıcının biletlerini çek
      final userTickets = await _firebaseService.getUserTickets();
      tickets.assignAll(userTickets);

      // checked_in olan bilet var mı kontrol et
      final checkedIn =
          userTickets.where((t) => t.status == 'checked_in').toList();
      if (checkedIn.isNotEmpty) {
        checkedInTicket.value = checkedIn.first;
        await _loadActiveTourDetail(checkedIn.first.tourId);
      }

      // Tüm biletlerin tur bilgilerini çek (cache)
      for (final ticket in userTickets) {
        if (!ticketTours.containsKey(ticket.tourId)) {
          final tour = await _firebaseService.getTourById(ticket.tourId);
          if (tour != null) {
            ticketTours[ticket.tourId] = tour;
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Veriler yüklenirken hata oluştu.';
      debugPrint('MyToursController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadActiveTourDetail(String tourId) async {
    final tour = await _firebaseService.getTourById(tourId);
    if (tour != null) {
      activeTour.value = tour;
      final program = await _firebaseService.getTourProgram(tourId);
      programDays.assignAll(program);
    }
  }

  // Aktif (checked_in) bir bilet var mı?
  bool get hasCheckedIn =>
      checkedInTicket.value != null || isTestCheckedIn.value;

  // Yaklaşan turlar: active durumundaki biletler
  List<TicketModel> get upcomingTickets =>
      tickets.where((t) => t.status == 'active').toList();

  // Geçmiş turlar: completed veya cancelled durumundaki biletler
  List<TicketModel> get pastTickets =>
      tickets
          .where((t) => t.status == 'completed' || t.status == 'cancelled')
          .toList();

  // 🧪 Test: QR taranmış gibi simüle et
  Future<void> simulateCheckIn() async {
    // Bilet yoksa, DB'den herhangi bir aktif turu al
    isTestCheckedIn.value = true;

    if (tickets.isNotEmpty) {
      final testTicket =
          upcomingTickets.isNotEmpty ? upcomingTickets.first : tickets.first;
      checkedInTicket.value = testTicket;
      await _loadActiveTourDetail(testTicket.tourId);
    } else {
      // Bilet yok, doğrudan aktif turlardan birini yükle
      final tours = await _firebaseService.getActiveTours();
      if (tours.isNotEmpty) {
        // Program olan ilk turu bul
        for (final t in tours) {
          final program = await _firebaseService.getTourProgram(t.id);
          if (program.isNotEmpty) {
            activeTour.value = t;
            programDays.assignAll(program);
            break;
          }
        }
        // Programı olan bulunamadıysa ilk turu göster
        if (activeTour.value == null) {
          activeTour.value = tours.first;
        }
      }
    }

    Get.snackbar(
      '🧪 Test Modu',
      'QR taranmış gibi simüle edildi.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  // 🧪 Test: Simülasyonu geri al
  void resetCheckIn() {
    isTestCheckedIn.value = false;
    checkedInTicket.value = null;
    activeTour.value = null;
    programDays.clear();

    // Gerçek checked_in bilet varsa geri yükle
    final realCheckedIn =
        tickets.where((t) => t.status == 'checked_in').toList();
    if (realCheckedIn.isNotEmpty) {
      checkedInTicket.value = realCheckedIn.first;
      _loadActiveTourDetail(realCheckedIn.first.tourId);
    }

    Get.snackbar(
      '🧪 Test Modu',
      'Bilet listesine geri dönüldü.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.slate700,
      colorText: Colors.white,
    );
  }

  Future<void> refresh() => loadData();
}

// ── Screen ──────────────────────────────────────────────────
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // checked_in durumu → Aktif Tur Detayları ekranı
          if (controller.hasCheckedIn && controller.activeTour.value != null) {
            return _ActiveTourDetailView(controller: controller);
          }

          // Normal durum → Bilet listesi
          return _TicketListView(controller: controller);
        }),
      ),
      bottomNavigationBar:
          BottomNavBar(activeIndex: 1, onItemTapped: _onItemTapped),
      // 🧪 Test butonu
      floatingActionButton: Obx(() {
        return FloatingActionButton.extended(
          onPressed: () {
            if (controller.hasCheckedIn) {
              controller.resetCheckIn();
            } else {
              controller.simulateCheckIn();
            }
          },
          backgroundColor:
              controller.hasCheckedIn ? AppColors.slate700 : AppColors.primary,
          icon: Icon(
            controller.hasCheckedIn ? Icons.undo : Icons.qr_code_scanner,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            controller.hasCheckedIn ? 'Listeye Dön' : 'QR Tara (Test)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
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
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.refresh(),
              color: AppColors.primary,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = list[index];
                  final tour = controller.ticketTours[ticket.tourId];
                  return _buildTicketCard(ticket, tour);
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
            onPressed: () => Get.back(),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            splashRadius: 24,
          ),
          const Expanded(
            child: Text(
              'Turlarım',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
          border: Border(
            bottom: BorderSide(color: AppColors.slate800, width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildTab('Yaklaşan Turlar', 0),
            _buildTab('Geçmiş Turlar', 1),
          ],
        ),
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

  Widget _buildTicketCard(TicketModel ticket, TourModel? tour) {
    final dateStr =
        DateFormat('dd MMMM yyyy', 'tr_TR').format(ticket.purchaseDate);
    final tourTitle = tour?.title ?? 'Tur';
    final companyName = tour?.guideName ?? '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate800),
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
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.slate300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.qr_code_2, color: AppColors.primary, size: 40),
        ],
      ),
    );
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
    final tour = controller.activeTour.value!;
    final program = controller.programDays;

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                  _buildGuideCard(
                    tour.guideName ?? 'Rehber',
                    tour.busInfo.phoneNumber,
                  ),
                  const SizedBox(height: 28),
                  if (program.isNotEmpty)
                    _buildProgramSection(program, tour.createdAt),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
            splashRadius: 24,
          ),
          const Expanded(
            child: Text(
              'Aktif Tur Detayları',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
        color: const Color(0xFF22c55e).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF22c55e).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF22c55e),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'TUR AKTİF',
            style: TextStyle(
              color: Color(0xFF22c55e),
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
            child: const Icon(
              Icons.directions_bus,
              color: AppColors.primary,
              size: 24,
            ),
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
            child: const Icon(
              Icons.account_circle,
              color: AppColors.primary,
              size: 24,
            ),
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

  Widget _buildProgramSection(
    List<TourProgramDay> programDays,
    DateTime tourDate,
  ) {
    final dateStr = DateFormat('d MMMM yyyy', 'tr_TR').format(tourDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    final timeBgColor =
        isActive ? AppColors.primary.withOpacity(0.2) : AppColors.slate800;
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
                    decoration: BoxDecoration(
                      color: dotInnerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 72, color: AppColors.slate800),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                      fontWeight:
                          isActive ? FontWeight.w500 : FontWeight.normal,
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
