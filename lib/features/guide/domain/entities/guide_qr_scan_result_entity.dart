class GuideQrScanResultEntity {
  const GuideQrScanResultEntity({
    required this.success,
    required this.code,
    required this.message,
    this.passengerName = '',
  });

  final bool success;
  final String code;
  final String message;
  final String passengerName;
}
