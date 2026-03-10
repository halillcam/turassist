import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/tour_model.dart';
import '../../../../core/models/tour_program_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/ticket_service.dart';
import '../../../../core/services/tour_service.dart';
import '../../domain/repositories/tours_repository.dart';

class ToursRepositoryImpl implements ToursRepository {
  ToursRepositoryImpl({
    TourService? tourService,
    TicketService? ticketService,
    AuthService? authService,
  }) : _tourService = tourService ?? TourService(),
       _ticketService = ticketService ?? TicketService(),
       _authService = authService ?? AuthService();

  final TourService _tourService;
  final TicketService _ticketService;
  final AuthService _authService;

  @override
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) {
    return _ticketService.createTicket(ticket);
  }

  @override
  String getCurrentUserId() {
    return _authService.getCurrentUserId();
  }

  @override
  Future<UserModel?> getCurrentUserProfile() {
    return _authService.getUserProfile();
  }

  @override
  Future<List<TicketModel>> getUserTickets() {
    return _ticketService.getUserTickets();
  }

  @override
  Future<TourModel?> getTourById(String tourId) {
    return _tourService.getTourById(tourId);
  }

  @override
  Future<List<TourProgramDay>> getTourProgram(String tourId) {
    return _tourService.getTourProgram(tourId);
  }

  @override
  Future<List<TourModel>> getTours({String? city}) {
    if (city == null || city.trim().isEmpty) {
      return _tourService.getActiveTours();
    }
    return _tourService.getToursByCity(city.trim());
  }

  @override
  Future<Map<String, int>> getSlotTicketCounts(String tourId, List<String> slotIds) {
    return _ticketService.getSlotTicketCounts(tourId, slotIds);
  }

  @override
  Future<bool> updateTicketQrStatus(String ticketId) {
    return _ticketService.updateTicketQRStatus(ticketId);
  }

  @override
  Future<bool> updateTicketStatus(String ticketId, String newStatus) {
    return _ticketService.updateTicketStatus(ticketId, newStatus);
  }

  @override
  Stream<List<TicketModel>> watchUserTickets() {
    return _ticketService.getUserTicketsStream();
  }
}
