import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/tour_model.dart';
import '../../../../core/models/tour_program_model.dart';
import '../../../../core/models/user_model.dart';

abstract class ToursRepository {
  Future<List<TourModel>> getTours({String? city});
  Future<TourModel?> getTourById(String tourId);
  Future<List<TourProgramDay>> getTourProgram(String tourId);
  Future<Map<String, int>> getSlotTicketCounts(String tourId, List<String> slotIds);
  Future<UserModel?> getCurrentUserProfile();
  String getCurrentUserId();
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket);
  Future<List<TicketModel>> getUserTickets();
  Stream<List<TicketModel>> watchUserTickets();
  Future<bool> updateTicketStatus(String ticketId, String newStatus);
  Future<bool> updateTicketQrStatus(String ticketId);
}
