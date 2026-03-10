import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../data/repositories/guide_repository_impl.dart';
import '../../domain/entities/guide_dashboard_entity.dart';
import '../../domain/usecases/get_guide_dashboard_use_case.dart';
import '../../domain/usecases/request_tour_completion_use_case.dart';

class GuideDashboardController extends GetxController {
  GuideDashboardController({
    required GetGuideDashboardUseCase getGuideDashboardUseCase,
    required RequestTourCompletionUseCase requestTourCompletionUseCase,
  }) : _getGuideDashboardUseCase = getGuideDashboardUseCase,
       _requestTourCompletionUseCase = requestTourCompletionUseCase;

  factory GuideDashboardController.createDefault() {
    final repository = GuideRepositoryImpl();
    return GuideDashboardController(
      getGuideDashboardUseCase: GetGuideDashboardUseCase(repository),
      requestTourCompletionUseCase: RequestTourCompletionUseCase(repository),
    );
  }

  final GetGuideDashboardUseCase _getGuideDashboardUseCase;
  final RequestTourCompletionUseCase _requestTourCompletionUseCase;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<GuideDashboardEntity> dashboard = Rxn<GuideDashboardEntity>();

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      dashboard.value = await _getGuideDashboardUseCase.execute();
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> requestTourCompletion() async {
    final currentDashboard = dashboard.value;
    if (currentDashboard == null || !currentDashboard.hasAssignedTour) {
      throw Exception('Aktif tur bulunamadı.');
    }
    if (currentDashboard.hasPendingCompletionRequest) {
      throw Exception('İstek zaten gönderildi. Admin onayı bekleniyor.');
    }

    isSubmitting.value = true;
    try {
      await _requestTourCompletionUseCase.execute(
        tourId: currentDashboard.tourId,
        guideId: currentDashboard.guideId,
      );
      await loadDashboard();
      return 'Talep admin onayına gönderildi.';
    } catch (error) {
      throw Exception(_mapTourCompletionError(error));
    } finally {
      isSubmitting.value = false;
    }
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
}
