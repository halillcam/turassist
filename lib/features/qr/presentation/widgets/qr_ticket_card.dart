import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/colors.dart';

class QrTicketCard extends StatelessWidget {
  const QrTicketCard({
    super.key,
    required this.title,
    required this.description,
    required this.hasValidQr,
    required this.qrToken,
  });

  final String title;
  final String description;
  final bool hasValidQr;
  final String qrToken;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate700),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: hasValidQr
                  ? AppColors.primary.withOpacity(0.14)
                  : AppColors.error.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              hasValidQr ? 'AKTİF BİLET' : 'GEÇERSİZ QR',
              style: TextStyle(
                color: hasValidQr ? AppColors.primary : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate400, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasValidQr ? Colors.white : AppColors.slate900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: hasValidQr ? Colors.white : AppColors.slate700),
            ),
            child: hasValidQr
                ? QrImageView(data: qrToken, size: 230)
                : const SizedBox(
                    width: 230,
                    height: 230,
                    child: Center(child: Icon(Icons.block, color: AppColors.error, size: 56)),
                  ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.slate800.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  hasValidQr ? Icons.info_outline : Icons.warning_amber_rounded,
                  color: hasValidQr ? AppColors.primary : AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValidQr
                        ? 'Bu kodu tur sorumlusuna gösterin. Okutulduğunda ekran otomatik güncellenecek.'
                        : 'Bu biletin QR kodu okutulmuş, iptal edilmiş ya da artık kullanılamaz durumda.',
                    style: const TextStyle(color: AppColors.slate300, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
