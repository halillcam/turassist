import 'package:get/get.dart';
import 'package:turassist/models/ticket_model.dart';
import 'package:turassist/models/announcement_model.dart';
import 'package:turassist/models/tour_model.dart';
import 'package:turassist/services/firebase_service.dart';

class GuideController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var selectedTour = Rxn<TourModel>();
  var tourTickets = <TicketModel>[].obs;
  var announcements = <AnnouncementModel>[].obs;
  var isLoading = false.obs;
  var announcementTitle = ''.obs;
  var announcementContent = ''.obs;

  Future<void> loadTourDetails(String tourId) async {
    isLoading.value = true;
    try {
      final tour = await _firebaseService.getTourById(tourId);
      selectedTour.value = tour;

      if (tour != null) {
        final tickets = await _firebaseService.getTourTickets(tourId);
        tourTickets.value = tickets;
      }
    } catch (e) {
      print('Error loading tour details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadAnnouncements(String tourId) {
    _firebaseService.getAnnouncements(tourId).listen((announcementList) {
      announcements.value = announcementList;
    });
  }

  Future<void> createAnnouncement({
    required String tourId,
    required String guideId,
    required bool isUrgent,
  }) async {
    if (announcementTitle.value.isEmpty || announcementContent.value.isEmpty) {
      Get.snackbar('Hata', 'Lütfen başlık ve içerik doldurunuz');
      return;
    }

    try {
      final announcement = AnnouncementModel(
        id: '',
        tourId: tourId,
        guideId: guideId,
        title: announcementTitle.value,
        content: announcementContent.value,
        createdAt: DateTime.now(),
        isUrgent: isUrgent,
      );

      await _firebaseService.createAnnouncement(announcement);
      announcementTitle.value = '';
      announcementContent.value = '';
      Get.snackbar('Başarılı', 'Bildirim gönderildi');
    } catch (e) {
      print('Error creating announcement: $e');
      Get.snackbar('Hata', 'Bildirim gönderilemedi');
    }
  }

  Future<void> scanQRCode(String ticketId, String qrCode) async {
    try {
      final success = await _firebaseService.updateTicketQRStatus(ticketId, qrCode, true);
      if (success) {
        Get.snackbar('Başarılı', 'QR Kod başarıyla tarandı');
        if (selectedTour.value != null) {
          await loadTourDetails(selectedTour.value!.id);
        }
      }
    } catch (e) {
      print('Error scanning QR: $e');
      Get.snackbar('Hata', 'QR Kod taranamadı');
    }
  }
}
