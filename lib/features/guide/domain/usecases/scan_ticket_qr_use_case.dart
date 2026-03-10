import '../entities/guide_qr_scan_result_entity.dart';
import '../repositories/guide_repository.dart';

class ScanTicketQrUseCase {
  ScanTicketQrUseCase(this._repository);

  final GuideRepository _repository;

  Future<GuideQrScanResultEntity> execute({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) {
    return _repository.scanQr(
      qrToken: qrToken,
      expectedTourId: expectedTourId,
      expectedDate: expectedDate,
    );
  }
}
