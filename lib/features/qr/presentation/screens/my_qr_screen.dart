import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/my_qr_controller.dart';
import '../widgets/qr_ticket_card.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  late final MyQrController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MyQrController());
    _controller.initialize(Get.arguments);
  }

  @override
  void dispose() {
    Get.delete<MyQrController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text("QR'larım", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.slate900.withOpacity(0.95)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final ticket = _controller.ticket.value;
              final qrToken = ticket?.qrToken ?? '';
              return QrTicketCard(
                title: _controller.tourTitle.value,
                description: _controller.hasValidQr
                    ? 'Tur sorumlusuna bu QR kodu okutun'
                    : 'Bu biletin QR kodu artık geçerli değil',
                hasValidQr: _controller.hasValidQr,
                qrToken: qrToken,
              );
            }),
          ),
        ),
      ),
    );
  }
}
