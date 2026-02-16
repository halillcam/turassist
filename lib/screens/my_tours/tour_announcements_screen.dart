import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/colors.dart';
import '../../controllers/announcement_controller.dart';

/// Customer tarafı: sadece aktif tur (QR okutulan tur) duyurularını gösterir.
class TourAnnouncementsScreen extends StatefulWidget {
  const TourAnnouncementsScreen({super.key});

  @override
  State<TourAnnouncementsScreen> createState() => _TourAnnouncementsScreenState();
}

class _TourAnnouncementsScreenState extends State<TourAnnouncementsScreen> {
  late final String _controllerTag;
  late final AnnouncementController _announcementController;
  late final String _tourId;
  late final String _tourTitle;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'customer-ann-${UniqueKey()}';
    _announcementController = Get.put(AnnouncementController(), tag: _controllerTag);

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _tourId = args['tourId']?.toString() ?? '';
    _tourTitle = args['tourTitle']?.toString() ?? 'Tur Duyuruları';

    if (_tourId.isNotEmpty) {
      _announcementController.listenAnnouncements(_tourId);
    }
  }

  @override
  void dispose() {
    Get.delete<AnnouncementController>(tag: _controllerTag, force: true);
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
            Expanded(
              child: Obx(() {
                if (_announcementController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final err = _announcementController.errorMessage.value;
                if (err.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            err,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.errorLight, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => _announcementController.listenAnnouncements(_tourId),
                            child: const Text('Tekrar dene', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final announcements = _announcementController.announcements;
                if (announcements.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bu tur için henüz duyuru yok.',
                      style: TextStyle(color: AppColors.slate400, fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: announcements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = announcements[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.slate800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format(item.createdAt),
                            style: const TextStyle(
                              color: AppColors.slate500,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.notification,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            splashRadius: 24,
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Tur Duyuruları',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  _tourTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
