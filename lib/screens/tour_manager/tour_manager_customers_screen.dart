import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';

class TourManagerCustomersScreen extends StatefulWidget {
  const TourManagerCustomersScreen({super.key});

  @override
  State<TourManagerCustomersScreen> createState() => _TourManagerCustomersScreenState();
}

class _TourManagerCustomersScreenState extends State<TourManagerCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0: Tümü, 1: Gelenler, 2: Gelmeyenler

  final List<_Participant> _allParticipants = [
    _Participant(name: 'Caner Yılmaz', phone: '0532 123 45 67', arrived: true, isVip: true),
    _Participant(name: 'Merve Aydın', phone: '0544 987 65 43', arrived: false),
    _Participant(name: 'Ahmet Demir', phone: '0505 111 22 33', arrived: true),
    _Participant(name: 'Selin Kaya', phone: '0536 444 55 66', arrived: false),
    _Participant(name: 'Emre Can', phone: '0552 777 88 99', arrived: false),
  ];

  List<_Participant> get _filteredParticipants {
    var list = _allParticipants;
    // Tab filtresi
    if (_selectedTab == 1) {
      list = list.where((p) => p.arrived).toList();
    } else if (_selectedTab == 2) {
      list = list.where((p) => !p.arrived).toList();
    }
    // Arama filtresi
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(query) || p.phone.contains(query))
          .toList();
    }
    return list;
  }

  int get _arrivedCount => _allParticipants.where((p) => p.arrived).length;
  int get _pendingCount => _allParticipants.where((p) => !p.arrived).length;

  @override
  void dispose() {
    _searchController.dispose();
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
            Expanded(child: _buildParticipantList()),
          ],
        ),
      ),
    );
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
            onTap: () => Get.back(),
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
              children: const [
                Text(
                  'Katılımcı Listesi',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Büyük Kanyon Ekspresi #402',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a2632),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF324d67)),
        ),
        child: Row(
          children: [
            _statItem('TOPLAM', '${_allParticipants.length}', AppColors.white),
            _divider(),
            _statItem('GELEN', '$_arrivedCount', const Color(0xFF10b981)),
            _divider(),
            _statItem('BEKLENEN', '$_pendingCount', const Color(0xFFf43f5e)),
          ],
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
              color: const Color(0xFF233648),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF92adc9), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Katılımcı ara...',
                      hintStyle: TextStyle(color: const Color(0xFF92adc9), fontSize: 14),
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
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFF324d67), width: 1)),
            ),
            child: Row(
              children: [
                _tabItem('Tümü (${_allParticipants.length})', 0),
                const SizedBox(width: 24),
                _tabItem('Gelenler ($_arrivedCount)', 1),
                const SizedBox(width: 24),
                _tabItem('Gelmeyenler ($_pendingCount)', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.white : const Color(0xFF92adc9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Participant List ──
  Widget _buildParticipantList() {
    final participants = _filteredParticipants;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: participants.length,
            separatorBuilder: (_, __) => Container(height: 1, color: AppColors.slate800),
            itemBuilder: (context, index) {
              return _buildParticipantTile(participants[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantTile(_Participant participant) {
    final initials = participant.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final borderColor = participant.arrived
        ? const Color(0xFF10b981).withOpacity(0.3)
        : AppColors.slate800;

    return Container(
      color: const Color(0xFF111a22),
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
          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      participant.phone,
                      style: const TextStyle(color: Color(0xFF92adc9), fontSize: 12),
                    ),
                    if (participant.isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.slate800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          _statusBadge(participant.arrived),
        ],
      ),
    );
  }

  Widget _statusBadge(bool arrived) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: arrived
            ? const Color(0xFF10b981).withOpacity(0.1)
            : const Color(0xFFf43f5e).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: arrived
              ? const Color(0xFF10b981).withOpacity(0.2)
              : const Color(0xFFf43f5e).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            arrived ? Icons.check_circle : Icons.cancel,
            color: arrived ? const Color(0xFF10b981) : const Color(0xFFf43f5e),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            arrived ? 'Geldi' : 'Gelmedi',
            style: TextStyle(
              color: arrived ? const Color(0xFF34d399) : const Color(0xFFfb7185),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Participant {
  final String name;
  final String phone;
  final bool arrived;
  final bool isVip;

  const _Participant({
    required this.name,
    required this.phone,
    required this.arrived,
    this.isVip = false,
  });
}
