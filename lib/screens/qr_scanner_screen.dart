import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/guide_controller.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GuideController controller = Get.put(GuideController());
  late MobileScannerController scannerController;
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'QR Kod Tara',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (isScanning && barcode.rawValue != null) {
                  isScanning = false;
                  _handleQRCodeScanned(barcode.rawValue!);
                }
              }
            },
          ),
          // Scanner overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 150),
          ),
          // Info at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QR Kod Tara',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yolcunun biletindeki QR kodu kameranın içine getirin',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          scannerController.toggleTorch();
                        },
                        icon: const Icon(Icons.flashlight_on),
                        label: const Text('Işık'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Kapat'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCodeScanned(String qrCode) {
    // Show success dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'QR Kod Başarıyla Tarandı!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                qrCode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              isScanning = true;
            },
            child: const Text('Devam Et', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}
