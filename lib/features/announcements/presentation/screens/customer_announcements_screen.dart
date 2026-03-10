import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/announcement_controller.dart';
import '../widgets/announcement_app_bar.dart';
import '../widgets/announcement_list_view.dart';
import '../widgets/announcement_status_view.dart';

class CustomerAnnouncementsScreen extends StatefulWidget {
  const CustomerAnnouncementsScreen({super.key});

  @override
  State<CustomerAnnouncementsScreen> createState() => _CustomerAnnouncementsScreenState();
}

class _CustomerAnnouncementsScreenState extends State<CustomerAnnouncementsScreen> {
  late final AnnouncementController _controller;
  late final String _tourId;
  late final String _tourTitle;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AnnouncementController(), tag: 'customer-announcements');
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _tourId = args['tourId']?.toString().trim() ?? '';
    _tourTitle = args['tourTitle']?.toString().trim() ?? 'Tur Duyuruları';
    _controller.initialize(_tourId);
  }

  @override
  void dispose() {
    Get.delete<AnnouncementController>(tag: 'customer-announcements', force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            AnnouncementAppBar(title: 'Tur Duyuruları', subtitle: _tourTitle),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value || _controller.errorMessage.value.isNotEmpty) {
                  return AnnouncementStatusView(
                    isLoading: _controller.isLoading.value,
                    errorMessage: _controller.errorMessage.value,
                    onRetry: _controller.retry,
                  );
                }

                return AnnouncementListView(
                  announcements: _controller.announcements,
                  emptyMessage: 'Bu tur için henüz duyuru yok.',
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
