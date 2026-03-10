import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../config/colors.dart';
import '../controllers/guide_qr_scanner_controller.dart';

class GuideQrScannerScreen extends StatefulWidget {
  const GuideQrScannerScreen({super.key});

  @override
  State<GuideQrScannerScreen> createState() => _GuideQrScannerScreenState();
}

class _GuideQrScannerScreenState extends State<GuideQrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final GuideQrScannerController _controller;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
    autoZoom: true,
  );

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    _controller = Get.put(GuideQrScannerController.createDefault());
    _laserController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _laserAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _laserController, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(
        initialTourId: args['tourId']?.toString() ?? '',
        initialExpectedDate: args['tourDate']?.toString() ?? '',
      );
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _laserController.dispose();
    Get.delete<GuideQrScannerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    'Bilet Tara',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _scannerController.toggleTorch();
                      setState(() => _isFlashOn = !_isFlashOn);
                    },
                    icon: Icon(
                      _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: _handleDetect,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 24 + (_laserAnimation.value * 220),
                            left: 20,
                            right: 20,
                            child: Container(height: 2, color: AppColors.primary.withOpacity(0.8)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'QR okutulduğunda yolcu adı gösterilir ve durum listesi anında güncellenir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_controller.isProcessing.value || capture.barcodes.isEmpty) {
      return;
    }
    if (_controller.tourId.value.isEmpty) {
      Get.snackbar(
        'Tur Bulunamadı',
        'Tarama için önce tur sorumlusuna atanmış aktif tur gerekli.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    final raw = (capture.barcodes.first.rawValue ?? capture.barcodes.first.displayValue ?? '')
        .trim();
    if (raw.isEmpty) {
      return;
    }

    final result = await _controller.scan(raw);
    if (!mounted) {
      return;
    }
    if (result.success) {
      final passengerName = result.passengerName.isEmpty ? 'Yolcu' : result.passengerName;
      Get.snackbar(
        'Başarılı ✓',
        '$passengerName — QR doğrulandı, bilet girişe açıldı.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Get.back(result: true);
      }
      return;
    }

    Get.snackbar(
      'Geçersiz QR',
      '[${result.code}] ${result.message}',
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
