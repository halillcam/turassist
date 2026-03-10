import '../models/chat_model.dart';
import '../models/ticket_model.dart';
import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'ticket_service.dart';
import 'tour_service.dart';

export 'ticket_service.dart' show QrConsumeResult;

class FirebaseService {
  final AuthService _authService = AuthService();
  final TourService _tourService = TourService();
  final TicketService _ticketService = TicketService();
  final ChatService _chatService = ChatService();

  String getCurrentUserId() => _authService.getCurrentUserId();
  Future<UserModel?> getUserProfile() => _authService.getUserProfile();
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) => _authService.registerUser(email: email, password: password, name: name, surname: surname);
  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) =>
      _authService.loginAndCheckAuth(email, password, companyId);
  Future<UserModel?> customerLogin(String email, String password) =>
      _authService.customerLogin(email, password);
  Future<UserModel?> guideLogin(String guideId, String password) =>
      _authService.guideLogin(guideId, password);
  Future<void> logout() => _authService.logout();
  Future<void> resetPassword(String email) => _authService.resetPassword(email);
  Future<bool> isAuthorizedForCompany(String userId, String companyId) =>
      _authService.isAuthorizedForCompany(userId, companyId);

  Future<List<TourModel>> getActiveTours() => _tourService.getActiveTours();
  Future<List<TourModel>> getToursByCity(String city) => _tourService.getToursByCity(city);
  Future<List<String>> getAllCities() => _tourService.getAllCities();
  Future<TourModel?> getTourById(String tourId) => _tourService.getTourById(tourId);
  Future<TourModel?> getAssignedTourForGuide(String guideId) =>
      _tourService.getAssignedTourForGuide(guideId);
  Future<List<TourProgramDay>> getTourProgram(String tourId) => _tourService.getTourProgram(tourId);
  Future<void> updateTour(String tourId, TourModel tour) => _tourService.updateTour(tourId, tour);
  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) =>
      _tourService.getTourParticipants(tourId);
  Future<bool> hasPendingTourCompletionRequest({required String tourId, required String guideId}) =>
      _tourService.hasPendingTourCompletionRequest(tourId: tourId, guideId: guideId);
  Future<void> requestTourCompletion({required String tourId, required String guideId}) =>
      _tourService.requestTourCompletion(tourId: tourId, guideId: guideId);
  Future<void> finishTour(String tourId, String guideId) =>
      _tourService.requestTourCompletion(tourId: tourId, guideId: guideId);

  Future<int> getSlotTicketCount(String tourId, String slotId) =>
      _ticketService.getSlotTicketCount(tourId, slotId);
  Future<Map<String, int>> getSlotTicketCounts(String tourId, List<String> slotIds) =>
      _ticketService.getSlotTicketCounts(tourId, slotIds);
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) =>
      _ticketService.createTicket(ticket);
  Future<List<TicketModel>> getUserTickets() => _ticketService.getUserTickets();
  Stream<List<TicketModel>> getUserTicketsStream() => _ticketService.getUserTicketsStream();
  Future<String> generateQRToken({
    required String ticketId,
    required String tourId,
    required String userId,
  }) => _ticketService.generateQRToken(ticketId: ticketId, tourId: tourId, userId: userId);
  Future<void> updateTicketQRToken(String ticketId, String qrToken) =>
      _ticketService.updateTicketQRToken(ticketId, qrToken);
  Future<bool> updateTicketQRStatus(String ticketId) =>
      _ticketService.updateTicketQRStatus(ticketId);
  Future<bool> consumeTicketByQrToken({required String qrToken, required String expectedTourId}) =>
      _ticketService.consumeTicketByQrToken(qrToken: qrToken, expectedTourId: expectedTourId);
  Future<QrConsumeResult> consumeTicketByQrTokenDetailed({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) => _ticketService.consumeTicketByQrTokenDetailed(
    qrToken: qrToken,
    expectedTourId: expectedTourId,
    expectedDate: expectedDate,
  );
  Future<bool> updateTicketStatus(String ticketId, String newStatus) =>
      _ticketService.updateTicketStatus(ticketId, newStatus);

  Future<void> sendChatMessage(String tourId, ChatModel message) =>
      _chatService.sendChatMessage(tourId, message);
  Stream<List<ChatModel>> getChatMessages(String tourId) => _chatService.getChatMessages(tourId);
  Future<List<ChatModel>> getAllChatMessages(String tourId) =>
      _chatService.getAllChatMessages(tourId);
  Future<void> deleteChatMessage(String tourId, String messageId) =>
      _chatService.deleteChatMessage(tourId, messageId);
}
