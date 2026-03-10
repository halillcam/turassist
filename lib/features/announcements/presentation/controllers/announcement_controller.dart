import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/observe_announcements_use_case.dart';
import '../../domain/usecases/send_announcement_use_case.dart';

class AnnouncementController extends GetxController {
  AnnouncementController({AnnouncementRepository? repository})
    : _repository = repository ?? AnnouncementRepositoryImpl() {
    _observeAnnouncementsUseCase = ObserveAnnouncementsUseCase(_repository);
    _sendAnnouncementUseCase = SendAnnouncementUseCase(_repository);
  }

  final AnnouncementRepository _repository;
  late final ObserveAnnouncementsUseCase _observeAnnouncementsUseCase;
  late final SendAnnouncementUseCase _sendAnnouncementUseCase;

  final RxList<AnnouncementEntity> announcements = <AnnouncementEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString draftMessage = ''.obs;

  StreamSubscription<List<AnnouncementEntity>>? _subscription;
  String _tourId = '';

  int get maxLength => SendAnnouncementUseCase.maxLength;

  void initialize(String tourId) {
    _tourId = tourId.trim();
    if (_tourId.isEmpty) {
      errorMessage.value = 'Tur bilgisi bulunamadı.';
      announcements.clear();
      return;
    }
    _subscribe();
  }

  void updateDraft(String value) {
    draftMessage.value = value;
  }

  Future<void> retry() async {
    _subscribe();
  }

  Future<void> sendAnnouncement() async {
    try {
      isSubmitting.value = true;
      await _sendAnnouncementUseCase.execute(tourId: _tourId, message: draftMessage.value);
      draftMessage.value = '';
      Get.snackbar(
        'Başarılı',
        'Duyuru QR okutan katılımcılara gönderildi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Hata',
        _friendlyErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    isLoading.value = true;
    errorMessage.value = '';

    _subscription = _observeAnnouncementsUseCase
        .execute(_tourId)
        .listen(
          (items) {
            announcements.assignAll(items);
            errorMessage.value = '';
            isLoading.value = false;
          },
          onError: (error) {
            announcements.clear();
            errorMessage.value = _friendlyErrorMessage(error);
            isLoading.value = false;
          },
        );
  }

  String _friendlyErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission_denied') ||
        message.contains('missing or insufficient permissions')) {
      return 'Duyurular için erişim izni bulunamadı.';
    }
    if (message.contains('sadece tur sorumlusu')) {
      return 'Duyuru sadece tur sorumlusu tarafından gönderilebilir.';
    }
    if (message.contains('duyuru mesajı boş')) {
      return 'Duyuru mesajı boş olamaz.';
    }
    if (message.contains('tur bulunamadı')) {
      return 'Tur bilgisi bulunamadı.';
    }
    return 'Duyuru işlemi başarısız oldu. Lütfen tekrar deneyin.';
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
