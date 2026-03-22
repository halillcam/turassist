import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../guide/data/repositories/guide_repository_impl.dart';
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
  String _tourId = '';
  String _tourTitle = 'Atanmış tur yok';
  bool _isResolvingTour = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AnnouncementController(), tag: 'guide-announcements');
    _messageController = TextEditingController();
    _initializeTourContext();
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
                isSubmitting: _controller.isSubmitting.value || _isResolvingTour,
                canSend:
                    _tourId.isNotEmpty &&
                    !_isResolvingTour &&
                    _controller.draftMessage.value.trim().isNotEmpty,
                onChanged: _controller.updateDraft,
                onSend: _send,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_isResolvingTour) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (_controller.isLoading.value || _controller.errorMessage.value.isNotEmpty) {
                  return AnnouncementStatusView(
                    isLoading: _controller.isLoading.value,
                    errorMessage: _controller.errorMessage.value,
                    onRetry: _handleRetry,
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

  Future<void> _initializeTourContext() async {
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    var resolvedTourId = args['tourId']?.toString().trim() ?? '';
    var resolvedTourTitle = args['tourTitle']?.toString().trim() ?? '';

    if (resolvedTourId.isEmpty) {
      try {
        final dashboard = await GuideRepositoryImpl().getDashboard();
        resolvedTourId = dashboard.tourId.trim();
        if (resolvedTourTitle.isEmpty) {
          resolvedTourTitle = dashboard.tourTitle.trim();
        }
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _tourId = resolvedTourId;
      _tourTitle = resolvedTourTitle.isEmpty ? 'Atanmış tur yok' : resolvedTourTitle;
      _isResolvingTour = false;
    });

    _controller.initialize(_tourId);
  }

  Future<void> _send() async {
    await _controller.sendAnnouncement();
    if (!mounted) {
      return;
    }
    _messageController.clear();
  }

  Future<void> _handleRetry() async {
    if (_tourId.isEmpty) {
      setState(() {
        _isResolvingTour = true;
      });
      await _initializeTourContext();
      return;
    }

    await _controller.retry();
  }
}
