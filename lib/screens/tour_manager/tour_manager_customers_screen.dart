import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_routes.dart';
import '../../config/app_strings.dart';
import '../../config/colors.dart';
import '../../controllers/tour_manager_customers_controller.dart';

class TourManagerCustomersScreen extends StatefulWidget {
  const TourManagerCustomersScreen({super.key});

  @override
  State<TourManagerCustomersScreen> createState() => _TourManagerCustomersScreenState();
}

class _TourManagerCustomersScreenState extends State<TourManagerCustomersScreen> {
  late final TourManagerCustomersController _ctrl;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final tourId = args['tourId']?.toString().trim() ?? '';
    final tourTitle = args['tourTitle']?.toString().trim() ?? '';

    _ctrl = Get.put(TourManagerCustomersController());
    _ctrl.init(tourId: tourId, tourTitle: tourTitle);

    // Arama kutusundaki değişikliği controller'a aktar
    _searchController.addListener(() {
      _ctrl.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<TourManagerCustomersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatsBar(),
            _buildSearchAndTabs(),
            Expanded(
              child: Obx(
                () => _ctrl.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _buildParticipantList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBack() async {
    final didPop = await Navigator.of(context).maybePop();
    if (!didPop) {
      Get.offAllNamed(AppRoutes.tourManagerHome);
    }
  }

  // ── App Bar ──
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.backgroundDark.withOpacity(0.8)),
      child: Row(
        children: [
          // Geri
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 22),
            ),
          ),
          // Title
          Expanded(
            child: Column(
              children: [
                const Text(
                  AppStrings.participantList,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    _ctrl.tourTitle.value.isEmpty ? 'Atanmış tur yok' : _ctrl.tourTitle.value,
                    style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // More
          GestureDetector(
            onTap: () {},
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.more_horiz, color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Bar ──
  Widget _buildStatsBar() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate700),
          ),
          child: Row(
            children: [
              _statItem(AppStrings.statTotal, '${_ctrl.allParticipants.length}', AppColors.white),
              _divider(),
              _statItem(AppStrings.statArrived, '${_ctrl.arrivedCount}', AppColors.success),
              _divider(),
              _statItem(AppStrings.statPending, '${_ctrl.pendingCount}', AppColors.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: valueColor.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.slate700);
  }

  // ── Search & Tabs ──
  Widget _buildSearchAndTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.slate400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    // Arama listener initState’te eklendi — burada setState yok
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchParticipant,
                      hintStyle: TextStyle(color: AppColors.slate400, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tabs
          Obx(
            () => Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.slate700, width: 1)),
              ),
              child: Row(
                children: [
                  _tabItem('${AppStrings.tabAll} (${_ctrl.allParticipants.length})', 0),
                  const SizedBox(width: 24),
                  _tabItem('${AppStrings.tabArrived} (${_ctrl.arrivedCount})', 1),
                  const SizedBox(width: 24),
                  _tabItem('${AppStrings.tabNotArrived} (${_ctrl.pendingCount})', 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    return Obx(() {
      final isActive = _ctrl.selectedTab.value == index;
      return GestureDetector(
        onTap: () => _ctrl.selectedTab.value = index,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
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
            style: TextStyle(
              color: isActive ? AppColors.white : AppColors.slate400,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  // ── Participant List ──
  Widget _buildParticipantList() {
    final participants = _ctrl.filteredParticipants;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: participants.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Katılımcı bulunamadı.',
                      style: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: participants.length,
                  separatorBuilder: (_, _) => Container(height: 1, color: AppColors.slate800),
                  itemBuilder: (context, index) {
                    return _ParticipantTile(participant: participants[index]);
                  },
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Katılımcı satır kartı — StatelessWidget olarak extract edildi
// ══════════════════════════════════════════════════════════════
class _ParticipantTile extends StatelessWidget {
  final ParticipantItem participant;
  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final initials = participant.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final borderColor = participant.arrived
        ? AppColors.success.withOpacity(0.3)
        : AppColors.slate800;

    return Container(
      color: AppColors.slate900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.slate700,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // İsim & TC
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  participant.subtitle,
                  style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
              ],
            ),
          ),
          // Durum rozeti
          _StatusBadge(arrived: participant.arrived),
        ],
      ),
    );
  }
}

// Küçük durum rozeti — 2 satırlık yardımcı widget
class _StatusBadge extends StatelessWidget {
  final bool arrived;
  const _StatusBadge({required this.arrived});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: arrived ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: arrived ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            arrived ? Icons.check_circle : Icons.cancel,
            color: arrived ? AppColors.success : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            arrived ? AppStrings.arrivedLabel : AppStrings.notArrivedLabel,
            style: TextStyle(
              color: arrived ? AppColors.successLight : AppColors.errorLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
