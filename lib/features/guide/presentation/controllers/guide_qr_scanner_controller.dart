import 'package:get/get.dart';

import '../../data/repositories/guide_repository_impl.dart';
import '../../domain/entities/guide_qr_scan_result_entity.dart';
import '../../domain/usecases/get_guide_dashboard_use_case.dart';
import '../../domain/usecases/scan_ticket_qr_use_case.dart';

class GuideQrScannerController extends GetxController {
  GuideQrScannerController({
    required GetGuideDashboardUseCase getGuideDashboardUseCase,
    required ScanTicketQrUseCase scanTicketQrUseCase,
  }) : _getGuideDashboardUseCase = getGuideDashboardUseCase,
       _scanTicketQrUseCase = scanTicketQrUseCase;

  factory GuideQrScannerController.createDefault() {
    final repository = GuideRepositoryImpl();
    return GuideQrScannerController(
      getGuideDashboardUseCase: GetGuideDashboardUseCase(repository),
      scanTicketQrUseCase: ScanTicketQrUseCase(repository),
    );
  }

  final GetGuideDashboardUseCase _getGuideDashboardUseCase;
  final ScanTicketQrUseCase _scanTicketQrUseCase;

  final RxBool isProcessing = false.obs;
  final RxString tourId = ''.obs;
  final RxString expectedDate = ''.obs;

  Future<void> initialize({String initialTourId = '', String initialExpectedDate = ''}) async {
    tourId.value = initialTourId.trim();
    expectedDate.value = initialExpectedDate.trim();
    if (tourId.value.isNotEmpty) {
      return;
    }
    final dashboard = await _getGuideDashboardUseCase.execute();
    tourId.value = dashboard.tourId;
    expectedDate.value = dashboard.assignedSlotId ?? '';
  }

  Future<GuideQrScanResultEntity> scan(String rawValue) async {
    isProcessing.value = true;
    try {
      return await _scanTicketQrUseCase.execute(
        qrToken: rawValue,
        expectedTourId: tourId.value,
        expectedDate: expectedDate.value.isEmpty ? null : expectedDate.value,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
