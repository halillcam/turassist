import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_strings.dart';
import '../../config/colors.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class TourManagerHomeScreen extends StatefulWidget {
  const TourManagerHomeScreen({super.key});

  @override
  State<TourManagerHomeScreen> createState() => _TourManagerHomeScreenState();
}

class _GuideDashboardData {
  final String guideName;
  final String guideId;
  final String tourId;
  final String tourTitle;
  final String companyId;
  final int totalParticipants;
  final int checkedInParticipants;
  final String? assignedSlotId;
  final bool isGuideUser;
  final bool hasPendingCompletionRequest;

  const _GuideDashboardData({
    required this.guideName,
    this.guideId = '',
    this.tourId = '',
    this.tourTitle = '',
    this.companyId = '',
    this.totalParticipants = 0,
    this.checkedInParticipants = 0,
    this.assignedSlotId,
    this.isGuideUser = false,
    this.hasPendingCompletionRequest = false,
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

  bool get canShowFinishTourButton =>
      isGuideUser && guideId.trim().isNotEmpty && tourId.trim().isNotEmpty;
}

class _TourManagerHomeScreenState extends State<TourManagerHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final RxBool _isSubmittingCompletionRequest = false.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _assignedTourSubscription;

  /// Dashboard future — setState yerine Rx ile tetiklenir,
  /// sadece FutureBuilder’ı saran Obx yeniden çizer.
  late final Rx<Future<_GuideDashboardData>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = Rx<Future<_GuideDashboardData>>(_loadDashboardData());
    _bindAssignedTourListener();
  }

  @override
  void dispose() {
    _assignedTourSubscription?.cancel();
    super.dispose();
  }

  /// Dashboard verilerini yeniden yükler (pull-to-refresh & QR sonrası).
  Future<void> _refreshDashboard() async {
    final fresh = _loadDashboardData();
    _dashboardFuture.value = fresh; // Obx’i tetikler, setState gerekmez
    await fresh;
  }

  Future<void> _bindAssignedTourListener() async {
    final guideUid = await _resolveGuideId();
    if (!mounted || guideUid.isEmpty) return;

    await _assignedTourSubscription?.cancel();
    _assignedTourSubscription = FirebaseFirestore.instance
        .collection('tours')
        .where('guideId', isEqualTo: guideUid)
        .snapshots()
        .listen((_) {
          _dashboardFuture.value = _loadDashboardData();
        });
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
    final profile = await _firebaseService.getUserProfile();
    final isGuideUser = profile?.role.trim().toLowerCase() == 'guide';

    if (guideUid.isEmpty || !isGuideUser) {
      return _GuideDashboardData(guideName: guideName, guideId: guideUid, isGuideUser: isGuideUser);
    }

    final assignedTour = await _firebaseService.getAssignedTourForGuide(guideUid);
    if (assignedTour == null) {
      return _GuideDashboardData(guideName: guideName, guideId: guideUid, isGuideUser: isGuideUser);
    }

    final participants = await _firebaseService.getTourParticipants(assignedTour.id);
    bool hasPendingCompletionRequest = false;
    try {
      hasPendingCompletionRequest = await _firebaseService.hasPendingTourCompletionRequest(
        tourId: assignedTour.id,
        guideId: guideUid,
      );
    } catch (_) {
      hasPendingCompletionRequest = false;
    }

    // Atanmış turun slotId'sini bul (departureDate veya departureDates'ten)
    String? assignedSlotId;
    if (assignedTour.departureDate != null) {
      final d = assignedTour.departureDate!;
      assignedSlotId =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    } else if (assignedTour.departureDates != null && assignedTour.departureDates!.isNotEmpty) {
      final d = assignedTour.departureDates!.first;
      assignedSlotId =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    }

    final activeParticipants = participants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      if (status == 'cancelled') return false;

      // Eğer bilet tarihli slotId'ye sahipse, sadece atanmış turun tarihindeki yolcuları göster
      final slotId = item['slotId']?.toString() ?? '';
      final isDateSlot = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(slotId);
      if (isDateSlot && assignedSlotId != null && slotId != assignedSlotId) return false;

      return true;
    }).toList();

    final totalCount = activeParticipants.length;
    final checkedInCount = activeParticipants.where((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      final scanned = item['isScanned'] == true;
      return scanned || status == 'checked_in';
    }).length;

    return _GuideDashboardData(
      guideName: guideName,
      guideId: guideUid,
      tourId: assignedTour.id,
      tourTitle: assignedTour.title,
      companyId: assignedTour.companyId,
      totalParticipants: totalCount,
      checkedInParticipants: checkedInCount,
      assignedSlotId: assignedSlotId,
      isGuideUser: isGuideUser,
      hasPendingCompletionRequest: hasPendingCompletionRequest,
    );
  }

  String _mapTourCompletionError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bu işlem için yetkiniz yok. Firestore kurallarını kontrol edin.';
        case 'unavailable':
          return 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.';
        default:
          return error.message?.trim().isNotEmpty == true
              ? error.message!.trim()
              : 'Tur bitirme talebi gönderilemedi.';
      }
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    switch (raw) {
      case 'invalid-tour-completion-request':
        return 'Tur bitirme talebi için gerekli bilgiler eksik.';
      case 'guide-profile-not-found':
        return 'Guide profili bulunamadı. Tekrar giriş yapın.';
      case 'only-guide-can-request-tour-completion':
        return 'Sadece guide rolündeki kullanıcılar tur bitirme talebi oluşturabilir.';
      case 'tour-not-found':
        return 'Aktif tur bulunamadı.';
      case 'tour-already-inactive':
        return 'Tur zaten pasif görünüyor.';
      case 'guide-not-assigned-to-this-tour':
        return 'Yalnızca size atanmış tur için talep oluşturabilirsiniz.';
      case 'tour-completion-request-already-exists':
        return 'İstek zaten gönderildi. Admin onayı bekleniyor.';
      default:
        return raw.isEmpty ? 'Tur bitirme talebi gönderilemedi.' : raw;
    }
  }

  Future<void> _submitTourCompletionRequest(_GuideDashboardData dashboard) async {
    if (!dashboard.canShowFinishTourButton) return;
    if (dashboard.hasPendingCompletionRequest) {
      Get.snackbar(
        'Bilgi',
        'İstek zaten gönderildi. Admin onayı bekleniyor.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _isSubmittingCompletionRequest.value = true;
      await _firebaseService.requestTourCompletion(
        tourId: dashboard.tourId,
        guideId: dashboard.guideId,
      );
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      await _refreshDashboard();
      Get.snackbar(
        'Başarılı',
        'Talep admin onayına gönderildi.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Hata',
        _mapTourCompletionError(error),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isSubmittingCompletionRequest.value = false;
    }
  }

  /// Rehberin tam adını çözümler.
  ///
  /// Önce [AuthService.getGuideFullName] ile Firestore'dan arar;
  /// bulunamazsa SharedPreferences'taki önbellek adına döner.
  Future<String> _getGuideFullName() async {
    final uid = await _resolveGuideId();
    final prefs = await SharedPreferences.getInstance();
    final cachedName = (prefs.getString('guide_name') ?? '').trim();
    final fallback = cachedName.isEmpty ? 'Tur Sorumlusu' : cachedName;

    if (uid.isEmpty) return fallback;

    // Firestore'u servis katmanı üzerinden sorgula
    return _authService.getGuideFullName(uid, defaultName: fallback);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FutureBuilder<_GuideDashboardData>(
        future: _dashboardFuture.value,
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
                      _buildHeader(dashboard),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildTourTitle(
                              dashboard.tourTitle,
                              assignedSlotId: dashboard.assignedSlotId,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCards(
                              dashboard.totalParticipants,
                              dashboard.checkedInParticipants,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressCard(dashboard.pendingParticipants, dashboard.progress),
                            const SizedBox(height: 24),
                            _buildScanButton(
                              dashboard.tourId,
                              dashboard.tourTitle,
                              dashboard.assignedSlotId,
                            ),
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
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(_GuideDashboardData dashboard) {
    final guideName = dashboard.guideName;

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
            onTap: () => _showSettingsSheet(dashboard),
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
  Widget _buildTourTitle(String tourTitle, {String? assignedSlotId}) {
    // assignedSlotId'yi güzel formata çevir: "7 Mart 2026"
    String? formattedDate;
    if (assignedSlotId != null && assignedSlotId.length == 10) {
      try {
        final parts = assignedSlotId.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        const months = [
          '',
          'Ocak',
          'Şubat',
          'Mart',
          'Nisan',
          'Mayıs',
          'Haziran',
          'Temmuz',
          'Ağustos',
          'Eylül',
          'Ekim',
          'Kasım',
          'Aralık',
        ];
        formattedDate = '$day ${months[month]} $year';
      } catch (_) {}
    }

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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (formattedDate != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
          child: _StatCard(
            label: AppStrings.totalParticipants,
            value: '$totalCount',
            badge: totalCount == 0 ? 'Henüz katılımcı yok' : '%$occupancyPercent Katılım',
            badgeColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: AppStrings.checkedIn,
            value: '$checkedInCount',
            badge: totalCount == 0 ? '%0 Tamamlandı' : '%$occupancyPercent Tamamlandı',
            badgeColor: AppColors.primary,
            suffix: '/$totalCount',
          ),
        ),
      ],
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
  Widget _buildScanButton(String tourId, String tourTitle, String? assignedSlotId) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: tourId.trim().isEmpty
            ? null
            : () async {
                final result = await Get.toNamed(
                  '/qr-scanner',
                  arguments: {'tourId': tourId, 'tourTitle': tourTitle, 'tourDate': assignedSlotId},
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
          AppStrings.managementTools,
          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Katılımcıları Gör
        _ManagementTile(
          icon: Icons.checklist_rtl,
          iconColor: AppColors.success,
          iconBgColor: AppColors.primary.withOpacity(0.1),
          title: AppStrings.viewParticipants,
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
        _ManagementTile(
          icon: Icons.campaign,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withOpacity(0.12),
          title: AppStrings.makeAnnouncement,
          subtitle: AppStrings.notifyAllParticipants,
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
        _ManagementTile(
          icon: Icons.forum,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withOpacity(0.12),
          title: AppStrings.viewChat,
          subtitle: hasAssignedTour
              ? AppStrings.chatWithParticipants
              : AppStrings.tourAssignRequired,
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
  void _showSettingsSheet(_GuideDashboardData dashboard) {
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
            if (dashboard.canShowFinishTourButton) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() {
                  final isSubmitting = _isSubmittingCompletionRequest.value;
                  final hasPendingRequest = dashboard.hasPendingCompletionRequest;
                  final isDisabled = isSubmitting || hasPendingRequest;

                  return ElevatedButton.icon(
                    onPressed: isDisabled ? null : () => _submitTourCompletionRequest(dashboard),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.event_available, size: 20),
                    label: Text(
                      hasPendingRequest ? 'Onay Bekleniyor' : 'Turu Bitir',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPendingRequest ? AppColors.slate700 : AppColors.error,
                      disabledBackgroundColor: hasPendingRequest
                          ? AppColors.slate700
                          : AppColors.error.withOpacity(0.45),
                      disabledForegroundColor: AppColors.white,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                dashboard.hasPendingCompletionRequest
                    ? 'Talep gönderildi. Admin onayı gelene kadar tur aktif kalır.'
                    : 'Talep admin onayına gönderilir. Onay gelene kadar tur aktif kalır.',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final String? suffix;

  const _StatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final List<Widget>? badges;
  final bool showNotification;
  final bool showDot;
  final VoidCallback? onTap;

  const _ManagementTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.badges,
    this.showNotification = false,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        subtitle!,
                        style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                      ),
                    ],
                    if (badges != null) ...[const SizedBox(height: 6), Row(children: badges!)],
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
}
