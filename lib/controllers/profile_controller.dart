import 'package:get/get.dart';
import 'package:turassist/models/ticket_model.dart';
import 'package:turassist/models/chat_model.dart';
import 'package:turassist/models/announcement_model.dart';
import 'package:turassist/services/firebase_service.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  var userTickets = <TicketModel>[].obs;
  var isLoading = false.obs;
  var selectedTicket = Rxn<TicketModel>();
  var chatMessages = <ChatMessage>[].obs;
  var announcements = <AnnouncementModel>[].obs;
  var messageText = ''.obs;

  Future<void> loadUserTickets(String userId) async {
    isLoading.value = true;
    try {
      final tickets = await _firebaseService.getUserTickets(userId);
      userTickets.value = tickets;
    } catch (e) {
      print('Error loading user tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectTicket(TicketModel ticket) {
    selectedTicket.value = ticket;
    loadChatMessages(ticket.tourId);
    loadAnnouncements(ticket.tourId);
  }

  void loadChatMessages(String tourId) {
    _firebaseService.getChatMessages(tourId).listen((messages) {
      chatMessages.value = messages;
    });
  }

  void loadAnnouncements(String tourId) {
    _firebaseService.getAnnouncements(tourId).listen((announcementList) {
      announcements.value = announcementList;
    });
  }

  Future<void> sendMessage({
    required String tourId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    if (message.isEmpty) return;

    try {
      final chatMessage = ChatMessage(
        id: '',
        tourId: tourId,
        senderId: userId,
        senderName: userName,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firebaseService.sendChatMessage(chatMessage);
      messageText.value = '';
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
