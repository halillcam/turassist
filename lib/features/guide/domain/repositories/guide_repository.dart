import '../entities/guide_dashboard_entity.dart';
import '../entities/guide_participant_entity.dart';
import '../entities/guide_qr_scan_result_entity.dart';

abstract class GuideRepository {
  Future<GuideDashboardEntity> getDashboard();

  Future<List<GuideParticipantEntity>> getParticipants({required String tourId});

  Future<void> requestTourCompletion({required String tourId, required String guideId});

  Future<GuideQrScanResultEntity> scanQr({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  });
}
