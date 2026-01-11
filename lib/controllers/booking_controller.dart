import 'package:get/get.dart';
import 'package:turassist/models/ticket_model.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/services/firebase_service.dart';

class BookingController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var selectedTour = Rxn<TourModel>();
  var selectedDate = Rxn<DateTime>();
  var passengerName = ''.obs;
  var tcNo = ''.obs;
  var isProcessing = false.obs;
  var qrCode = ''.obs;

  void setTour(TourModel tour) {
    selectedTour.value = tour;
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setPassengerInfo(String name, String tc) {
    passengerName.value = name;
    tcNo.value = tc;
  }

  Future<bool> bookTour({required String userId, required String userName}) async {
    if (selectedTour.value == null || selectedDate.value == null || passengerName.value.isEmpty) {
      Get.snackbar('Hata', 'Lütfen tüm bilgileri doldurunuz');
      return false;
    }

    isProcessing.value = true;
    try {
      // Generate QR Code
      final qrData = '${selectedTour.value!.id}_${userId}_${selectedDate.value!.toIso8601String()}';
      qrCode.value = qrData;

      // Create ticket
      final ticket = TicketModel(
        id: '',
        tourId: selectedTour.value!.id,
        userId: userId,
        passengerName: passengerName.value,
        tcNo: tcNo.value,
        selectedDate: selectedDate.value!,
        pricePaid: selectedTour.value!.price,
        status: 'active',
        qrCode: qrData,
        qrScanned: false,
        purchaseDate: DateTime.now(),
      );

      final ticketId = await _firebaseService.createTicket(ticket);

      if (ticketId != null) {
        Get.snackbar('Başarılı', 'Bilet başarıyla satın alındı');
        return true;
      } else {
        Get.snackbar('Hata', 'Bilet oluşturulamadı');
        return false;
      }
    } catch (e) {
      print('Error booking tour: $e');
      Get.snackbar('Hata', 'Bilet satın alma başarısız oldu');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}
