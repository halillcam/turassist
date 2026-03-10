import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../core/models/ticket_model.dart';
import '../../../tours/presentation/controllers/my_tours_controller.dart';

class MyQrController extends GetxController {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _ticketSubscription;
  final Rxn<TicketModel> ticket = Rxn<TicketModel>();
  final RxString tourTitle = 'Tur Bileti'.obs;
  bool _navigated = false;

  void initialize(dynamic args) {
    if (args is Map<String, dynamic>) {
      final maybeTicket = args['ticket'];
      if (maybeTicket is TicketModel) {
        ticket.value = maybeTicket;
      }
      tourTitle.value = args['tourTitle']?.toString() ?? 'Tur Bileti';
    }

    final currentTicket = ticket.value;
    if (currentTicket == null || currentTicket.id.isEmpty) return;

    _ticketSubscription = FirebaseFirestore.instance
        .collection('tickets')
        .doc(currentTicket.id)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          if (data == null || _navigated) return;
          final isScanned = data['isScanned'] == true;
          final status = data['status']?.toString() ?? '';
          if (isScanned && status != 'cancelled' && status != 'completed') {
            _navigated = true;
            if (Get.isRegistered<MyToursController>()) {
              Get.delete<MyToursController>();
            }
            Get.offNamed(AppRoutes.myTours);
          }
        });
  }

  bool get hasValidQr {
    final qrToken = ticket.value?.qrToken;
    final isScanned = ticket.value?.isScanned == true;
    return qrToken != null && qrToken.trim().isNotEmpty && !isScanned;
  }

  @override
  void onClose() {
    _ticketSubscription?.cancel();
    super.onClose();
  }
}
