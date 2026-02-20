import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/colors.dart';
import '../../services/firebase_service.dart';

class TourManagerHomeScreen extends StatefulWidget {
  const TourManagerHomeScreen({super.key});

  @override
  State<TourManagerHomeScreen> createState() => _TourManagerHomeScreenState();
}

class _GuideDashboardData {
  final String guideName;
  final String tourId;
  final String tourTitle;
  final int totalParticipants;
  final int checkedInParticipants;

  const _GuideDashboardData({
    required this.guideName,
    this.tourId = '',
    this.tourTitle = '',
    this.totalParticipants = 0,
    this.checkedInParticipants = 0,
  });

  int get pendingParticipants {
    final pending = totalParticipants - checkedInParticipants;
    return pending < 0 ? 0 : pending;
  }

  double get progress {
    if (totalParticipants <= 0) return 0;
    final value = checkedInParticipants / totalParticipants;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}

class _TourManagerHomeScreenState extends State<TourManagerHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Future<_GuideDashboardData> _dashboardFuture = Future.value(
    const _GuideDashboardData(guideName: 'Tur Sorumlusu'),
  );

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  /// Dashboard verilerini yeniden yükler (pull-to-refresh & QR sonrası).
  Future<void> _refreshDashboard() async {
    final fresh = _loadDashboardData();
    setState(() {
      _dashboardFuture = fresh;
    });
    await fresh;
  }

  Future<String> _resolveGuideId() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuideSession = prefs.getBool('is_guide_session') ?? false;
    final persistedGuideId = (prefs.getString('guide_id') ?? '').trim();

    if (isGuideSession && persistedGuideId.isNotEmpty) {
      return persistedGuideId;
    }

    final firebaseUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (firebaseUid.trim().isNotEmpty) return firebaseUid;

    return persistedGuideId;
  }

  Future<_GuideDashboardData> _loadDashboardData() async {
    final guideUid = await _resolveGuideId();
    final guideName = await _getGuideFullName();

    if (guideUid.isEmpty) {
      return const _GuideDashboardData(guideName: 'Tur Sorumlusu');
    }

    final assignedTour = await _firebaseService.getAssignedTourForGuide(guideUid);
    if (assignedTour == null) {
      return _GuideDashboardData(guideName: guideName);
    }

    final participants = await _firebaseService.getTourParticipants(assignedTour.id);
    final activeParticipants = participants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      return status != 'cancelled';
    }).toList();

    final totalCount = activeParticipants.length;
    final checkedInCount = activeParticipants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      final scanned = item['isScanned'] == true;
      return scanned || status == 'checked_in';
    }).length;

    return _GuideDashboardData(
      guideName: guideName,
      tourId: assignedTour.id,
      tourTitle: assignedTour.title,
      totalParticipants: totalCount,
      checkedInParticipants: checkedInCount,
    );
  }

  Future<String> _getGuideFullName() async {
    final uid = await _resolveGuideId();
    if (uid.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = (prefs.getString('guide_name') ?? '').trim();
      return cachedName.isEmpty ? 'Tur Sorumlusu' : cachedName;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      final fullName = data?['fullName']?.toString().trim() ?? '';
      if (fullName.isNotEmpty) return fullName;
    }

    final guideDoc = await FirebaseFirestore.instance.collection('guides').doc(uid).get();
    if (guideDoc.exists) {
      final data = guideDoc.data();
      final fullName = data?['fullName']?.toString().trim() ?? '';
      if (fullName.isNotEmpty) return fullName;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedName = (prefs.getString('guide_name') ?? '').trim();
    return cachedName.isEmpty ? 'Tur Sorumlusu' : cachedName;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GuideDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final dashboard = snapshot.data ?? const _GuideDashboardData(guideName: 'Tur Sorumlusu');

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshDashboard,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(dashboard.guideName),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildTourTitle(dashboard.tourTitle),
                          const SizedBox(height: 16),
                          _buildStatCards(
                            dashboard.totalParticipants,
                            dashboard.checkedInParticipants,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressCard(dashboard.pendingParticipants, dashboard.progress),
                          const SizedBox(height: 24),
                          _buildScanButton(dashboard.tourId, dashboard.tourTitle),
                          const SizedBox(height: 28),
                          _buildManagementTools(
                            tourId: dashboard.tourId,
                            tourTitle: dashboard.tourTitle,
                            checkedInCount: dashboard.checkedInParticipants,
                            pendingCount: dashboard.pendingParticipants,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ──
  Widget _buildHeader(String guideName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.slate700),
                child: const Icon(Icons.person, color: AppColors.slate400, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideName.trim().isEmpty ? 'Tur Sorumlusu' : guideName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Tur Sorumlusu',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
              ],
            ),
          ),
          // Notification bell
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 8),
          // Settings button
          GestureDetector(
            onTap: _showSettingsSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tur Başlığı ──
  Widget _buildTourTitle(String tourTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tourTitle.trim().isEmpty ? 'Atanmış tur bulunamadı' : tourTitle,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── İstatistik kartları ──
  Widget _buildStatCards(int totalCount, int checkedInCount) {
    final occupancyPercent = totalCount == 0 ? 0 : ((checkedInCount / totalCount) * 100).round();
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'TOPLAM KATILIMCI',
            '$totalCount',
            totalCount == 0 ? 'Henüz katılımcı yok' : '%$occupancyPercent Katılım',
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'GİRİŞ YAPILDI',
            '$checkedInCount',
            totalCount == 0 ? '%0 Tamamlandı' : '%$occupancyPercent Tamamlandı',
            AppColors.primary,
            suffix: '/$totalCount',
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, String badge, Color badgeColor, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              children: suffix != null
                  ? [
                      TextSpan(
                        text: suffix,
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge,
            style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Giriş Durumu Progress ──
  Widget _buildProgressCard(int pendingCount, double progress) {
    final percentText = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giriş Durumu',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pendingCount misafir bekleniyor',
                    style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                  ),
                ],
              ),
              Text(
                '%$percentText',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.slate700,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── QR Tara Butonu ──
  Widget _buildScanButton(String tourId, String tourTitle) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: tourId.trim().isEmpty
            ? null
            : () async {
                final result = await Get.toNamed(
                  '/qr-scanner',
                  arguments: {'tourId': tourId, 'tourTitle': tourTitle},
                );
                // QR başarılıysa dashboard'u yenile
                if (result == true) {
                  _refreshDashboard();
                }
              },
        icon: const Icon(Icons.qr_code_scanner, size: 28),
        label: const Text(
          'QR Kodu Tara',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
    );
  }

  // ── Yönetim Araçları ──
  Widget _buildManagementTools({
    required String tourId,
    required String tourTitle,
    required int checkedInCount,
    required int pendingCount,
  }) {
    final hasAssignedTour = tourId.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yönetim Araçları',
          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Katılımcıları Gör
        _managementTile(
          icon: Icons.checklist_rtl,
          iconColor: AppColors.success,
          iconBgColor: AppColors.primary.withOpacity(0.1),
          title: 'Katılımcıları Gör',
          subtitle: null,
          badges: [
            _badge(Icons.check_circle, '$checkedInCount Giriş', AppColors.success),
            _badge(Icons.cancel, '$pendingCount Bekliyor', AppColors.error),
          ],
          showNotification: pendingCount > 0,
          onTap: !hasAssignedTour
              ? null
              : () {
                  Get.toNamed(
                    '/tour-manager-customers',
                    arguments: {'tourId': tourId, 'tourTitle': tourTitle},
                  );
                },
        ),
        const SizedBox(height: 12),
        // Duyuru Yap
        _managementTile(
          icon: Icons.campaign,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withOpacity(0.12),
          title: 'Duyuru Yap',
          subtitle: 'Tüm katılımcılara bildirim gönder',
          onTap: !hasAssignedTour
              ? null
              : () {
                  Get.toNamed(
                    '/tour-manager-announcements',
                    arguments: {'tourId': tourId, 'tourTitle': tourTitle},
                  );
                },
        ),
        const SizedBox(height: 12),
        // Sohbete Göz At
        _managementTile(
          icon: Icons.forum,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withOpacity(0.12),
          title: 'Sohbete Göz At',
          subtitle: hasAssignedTour ? 'Katılımcılar ile sohbet' : 'Önce tur ataması gerekli',
          showDot: hasAssignedTour,
          onTap: !hasAssignedTour
              ? null
              : () {
                  Get.toNamed(
                    '/tour-manager-chat',
                    arguments: {'tourId': tourId, 'tourTitle': tourTitle},
                  );
                },
        ),
      ],
    );
  }

  Widget _managementTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    List<Widget>? badges,
    bool showNotification = false,
    bool showDot = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate700),
          ),
          child: Row(
            children: [
              // Icon with optional notification badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  if (showNotification)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardDark, width: 2),
                        ),
                        child: const Icon(Icons.person_off, color: AppColors.white, size: 8),
                      ),
                    ),
                  if (showDot)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardDark, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                      ),
                    ],
                    if (badges != null) ...[const SizedBox(height: 6), Row(children: badges)],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Settings Bottom Sheet ──
  void _showSettingsSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.slate600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Turu Bitir
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.event_available, size: 20),
                label: const Text(
                  'Turu Bitir',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Turu bitirdiğinizde katılımcılardan değerlendirme istenir.',
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Çıkış Yap
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  SharedPreferences.getInstance().then((prefs) async {
                    await prefs.remove('is_guide_session');
                    await prefs.remove('guide_id');
                    await prefs.remove('guide_name');
                  });
                  Get.offAllNamed('/login');
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate300,
                  side: BorderSide(color: AppColors.slate600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
