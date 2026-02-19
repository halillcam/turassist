import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/colors.dart';
import '../../models/ticket_model.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    TicketModel? ticket;
    String tourTitle = 'Tur Bileti';

    if (args is Map<String, dynamic>) {
      final maybeTicket = args['ticket'];
      if (maybeTicket is TicketModel) {
        ticket = maybeTicket;
      }
      tourTitle = args['tourTitle']?.toString() ?? tourTitle;
    }

    final qrToken = ticket?.qrToken;
    final isScanned = ticket?.isScanned == true;
    final hasValidQr = qrToken != null && qrToken.trim().isNotEmpty && !isScanned;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: Get.back,
        ),
        title: const Text("QR'larım", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate700),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tourTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasValidQr
                        ? 'Tur sorumlusuna bu QR kodu okutun'
                        : 'Bu biletin QR kodu artık geçerli değil',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.slate400, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (hasValidQr)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(data: qrToken, size: 240),
                    )
                  else
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.slate900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate700),
                      ),
                      child: const Center(
                        child: Icon(Icons.block, color: AppColors.error, size: 56),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
