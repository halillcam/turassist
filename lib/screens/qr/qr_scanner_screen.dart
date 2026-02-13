import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _laserAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _laserController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Scanner area
            Expanded(child: _buildScannerArea()),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.close, color: AppColors.white, size: 22),
            ),
          ),
          // Title
          Column(
            children: [
              const Text(
                'Bilet Tara',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AKTİF',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Flash button
          GestureDetector(
            onTap: () {
              setState(() => _isFlashOn = !_isFlashOn);
              // TODO: Toggle flash
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isFlashOn
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFlashOn
                      ? AppColors.primary.withOpacity(0.4)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Icon(
                _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                color: _isFlashOn ? AppColors.primary : AppColors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scanner Area ──
  Widget _buildScannerArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Viewfinder
        _buildViewfinder(),
        const SizedBox(height: 40),
        // Hint text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            'QR kodu çerçeve içine hizalayın',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  // ── Viewfinder ──
  Widget _buildViewfinder() {
    const double size = 280;
    const double cornerSize = 48;
    const double cornerRadius = 32;
    const double borderWidth = 4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Base border
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
              borderRadius: BorderRadius.circular(cornerRadius),
              color: Colors.white.withOpacity(0.02),
            ),
          ),
          // Inner faint box
          Center(
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Corner: Top-Left
          Positioned(
            top: -1,
            left: -1,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.primary, width: borderWidth),
                  left: BorderSide(color: AppColors.primary, width: borderWidth),
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(cornerRadius)),
              ),
            ),
          ),
          // Corner: Top-Right
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.primary, width: borderWidth),
                  right: BorderSide(color: AppColors.primary, width: borderWidth),
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(cornerRadius)),
              ),
            ),
          ),
          // Corner: Bottom-Left
          Positioned(
            bottom: -1,
            left: -1,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: borderWidth),
                  left: BorderSide(color: AppColors.primary, width: borderWidth),
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(cornerRadius)),
              ),
            ),
          ),
          // Corner: Bottom-Right
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(
              width: cornerSize,
              height: cornerSize,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: borderWidth),
                  right: BorderSide(color: AppColors.primary, width: borderWidth),
                ),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(cornerRadius)),
              ),
            ),
          ),
          // Laser line (animated)
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return Positioned(
                top: _laserAnimation.value * (size - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
