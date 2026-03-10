import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../../../core/session/session_cleanup_service.dart';
import '../controllers/guide_dashboard_controller.dart';
import '../widgets/guide_action_tile.dart';
import '../widgets/guide_dashboard_header.dart';
import '../widgets/guide_empty_state.dart';
import '../widgets/guide_stats_row.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  late final GuideDashboardController _controller;
  final LogoutUseCase _logoutUseCase = LogoutUseCase(AuthRepositoryImpl(), SessionCleanupService());

  @override
  void initState() {
    super.initState();
    _controller = Get.put(GuideDashboardController.createDefault());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadDashboard();
    });
  }

  @override
  void dispose() {
    Get.delete<GuideDashboardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Tur Sorumlusu'),
        backgroundColor: AppColors.backgroundDark,
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded))],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (_controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                _controller.errorMessage.value,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final dashboard = _controller.dashboard.value;
          if (dashboard == null || !dashboard.hasAssignedTour) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: GuideEmptyState(
                message: dashboard?.isGuideUser == false
                    ? 'Bu panel sadece guide oturumları için açılır.'
                    : 'Tarama, katılımcı listesi ve grup chat için önce aktif tur ataması gerekli.',
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _controller.loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GuideDashboardHeader(dashboard: dashboard),
                const SizedBox(height: 16),
                GuideStatsRow(
                  total: dashboard.totalParticipants,
                  arrived: dashboard.checkedInParticipants,
                  pending: dashboard.pendingParticipants,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                  children: [
                    GuideActionTile(
                      icon: Icons.groups_rounded,
                      title: 'Katılımcılar',
                      subtitle: 'Yeşil/kırmızı durum listesi',
                      onTap: () => Get.toNamed(
                        AppRoutes.tourManagerCustomers,
                        arguments: {'tourId': dashboard.tourId, 'tourTitle': dashboard.tourTitle},
                      ),
                    ),
                    GuideActionTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Grup Chat',
                      subtitle: 'Guide, katılımcı ve müşteri sohbeti',
                      onTap: () => Get.toNamed(
                        AppRoutes.tourManagerChat,
                        arguments: {'tourId': dashboard.tourId, 'tourTitle': dashboard.tourTitle},
                      ),
                    ),
                    GuideActionTile(
                      icon: Icons.campaign_outlined,
                      title: 'Duyurular',
                      subtitle: 'Sadece guide gönderir',
                      onTap: () => Get.toNamed(AppRoutes.tourManagerAnnouncements),
                    ),
                    GuideActionTile(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'QR Tara',
                      subtitle: 'Tarama sonrası yolcu adı göster',
                      onTap: () async {
                        final refreshed = await Get.toNamed(
                          AppRoutes.qrScanner,
                          arguments: {
                            'tourId': dashboard.tourId,
                            'tourDate': dashboard.assignedSlotId,
                          },
                        );
                        if (refreshed == true) {
                          await _controller.loadDashboard();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: _controller.isSubmitting.value ? null : _confirmFinishTour,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _controller.isSubmitting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.flag_outlined),
                      label: Text(
                        dashboard.hasPendingCompletionRequest
                            ? 'Onay Bekleniyor'
                            : 'Turu Bitirme Talebi Gönder',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _confirmFinishTour() async {
    final approved = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Turu Bitir', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bu işlem admin onay talebi oluşturur. Devam etmek istiyor musunuz?',
          style: TextStyle(color: AppColors.slate300),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Gönder')),
        ],
      ),
    );
    if (approved != true) {
      return;
    }
    try {
      final message = await _controller.requestTourCompletion();
      Get.snackbar(
        'Başarılı',
        message,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Hata',
        error.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _logout() async {
    await _logoutUseCase.execute(redirectRoute: AppRoutes.login);
  }
}
