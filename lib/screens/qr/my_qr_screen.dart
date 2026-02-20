import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/app_routes.dart';
import '../../config/colors.dart';
import '../../controllers/my_tours_controller.dart';
import '../../models/ticket_model.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  StreamSubscription<DocumentSnapshot>? _ticketSub;
  bool _navigated = false;
  late final TicketModel? _ticket;
  late final String _tourTitle;

  @override
  void initState() {
    super.initState();
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

    _ticket = ticket;
    _tourTitle = tourTitle;

    // Bilet belgesini gerçek zamanlı dinle — rehber QR okuttuğunda
    // isScanned true olur ve kullanıcı otomatik aktif tur ekranına yönlendirilir.
    if (ticket != null && ticket.id.isNotEmpty) {
      _ticketSub = FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticket.id)
          .snapshots()
          .listen((snapshot) {
            if (!mounted || _navigated) return;
            final data = snapshot.data();
            if (data == null) return;

            final isScanned = data['isScanned'] == true;
            final status = data['status']?.toString() ?? '';

            if (isScanned || status == 'checked_in') {
              _navigated = true;
              _ticketSub?.cancel();

              // MyToursController'ı sıfırla ki yeni veriyi yüklesin
              if (Get.isRegistered<MyToursController>()) {
                Get.delete<MyToursController>();
              }

              Get.offNamed(AppRoutes.myTours);
            }
          });
    }
  }

  @override
  void dispose() {
    _ticketSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _ticket;
    final tourTitle = _tourTitle;

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
