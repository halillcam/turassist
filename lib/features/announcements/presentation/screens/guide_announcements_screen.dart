import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/announcement_controller.dart';
import '../widgets/announcement_app_bar.dart';
import '../widgets/announcement_compose_card.dart';
import '../widgets/announcement_list_view.dart';
import '../widgets/announcement_status_view.dart';

class GuideAnnouncementsScreen extends StatefulWidget {
  const GuideAnnouncementsScreen({super.key});

  @override
  State<GuideAnnouncementsScreen> createState() => _GuideAnnouncementsScreenState();
}

class _GuideAnnouncementsScreenState extends State<GuideAnnouncementsScreen> {
  late final AnnouncementController _controller;
  late final TextEditingController _messageController;
  late final String _tourId;
  late final String _tourTitle;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AnnouncementController(), tag: 'guide-announcements');
    _messageController = TextEditingController();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _tourId = args['tourId']?.toString().trim() ?? '';
    _tourTitle = args['tourTitle']?.toString().trim() ?? 'Atanmış tur yok';
    _controller.initialize(_tourId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    Get.delete<AnnouncementController>(tag: 'guide-announcements', force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            AnnouncementAppBar(title: 'Duyuru Gönder', subtitle: _tourTitle),
            Obx(
              () => AnnouncementComposeCard(
                controller: _messageController,
                maxLength: _controller.maxLength,
                isSubmitting: _controller.isSubmitting.value,
                onChanged: _controller.updateDraft,
                onSend: _send,
              ),
            ),
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

  Future<void> _send() async {
    await _controller.sendAnnouncement();
    if (!mounted) {
      return;
    }
    _messageController.clear();
  }
}
